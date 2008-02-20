From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tlan: add static to function definitions
Date: Wed, 20 Feb 2008 11:51:57 -0500
Message-ID: <47BC5AAD.7070100@garzik.org>
References: <1203357878.5757.26.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Samuel Chessman <chessman@tux.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48848 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259AbYBTQwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:52:01 -0500
In-Reply-To: <1203357878.5757.26.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> The forward declarations were already marked static, make the definitions
> be static as well.  Fixes the sparse warnings as well.
> 
> drivers/net/tlan.c:1403:5: warning: symbol 'TLan_HandleInvalid' was not declared. Should it be static?
> drivers/net/tlan.c:1435:5: warning: symbol 'TLan_HandleTxEOF' was not declared. Should it be static?
> drivers/net/tlan.c:1521:5: warning: symbol 'TLan_HandleStatOverflow' was not declared. Should it be static?
> drivers/net/tlan.c:1557:5: warning: symbol 'TLan_HandleRxEOF' was not declared. Should it be static?
> drivers/net/tlan.c:1692:5: warning: symbol 'TLan_HandleDummy' was not declared. Should it be static?
> drivers/net/tlan.c:1722:5: warning: symbol 'TLan_HandleTxEOC' was not declared. Should it be static?
> drivers/net/tlan.c:1770:5: warning: symbol 'TLan_HandleStatusCheck' was not declared. Should it be static?
> drivers/net/tlan.c:1845:5: warning: symbol 'TLan_HandleRxEOC' was not declared. Should it be static?
> drivers/net/tlan.c:1905:6: warning: symbol 'TLan_Timer' was not declared. Should it be static?
> drivers/net/tlan.c:1986:6: warning: symbol 'TLan_ResetLists' was not declared. Should it be static?
> drivers/net/tlan.c:2046:6: warning: symbol 'TLan_FreeLists' was not declared. Should it be static?
> drivers/net/tlan.c:2095:6: warning: symbol 'TLan_PrintDio' was not declared. Should it be static?
> drivers/net/tlan.c:2130:6: warning: symbol 'TLan_PrintList' was not declared. Should it be static?
> drivers/net/tlan.c:2166:6: warning: symbol 'TLan_ReadAndClearStats' was not declared. Should it be static?
> drivers/net/tlan.c:2242:1: warning: symbol 'TLan_ResetAdapter' was not declared. Should it be static?
> drivers/net/tlan.c:2328:1: warning: symbol 'TLan_FinishReset' was not declared. Should it be static?
> drivers/net/tlan.c:2451:6: warning: symbol 'TLan_SetMac' was not declared. Should it be static?
> drivers/net/tlan.c:2493:6: warning: symbol 'TLan_PhyPrint' was not declared. Should it be static?
> drivers/net/tlan.c:2542:6: warning: symbol 'TLan_PhyDetect' was not declared. Should it be static?
> drivers/net/tlan.c:2589:6: warning: symbol 'TLan_PhyPowerDown' was not declared. Should it be static?
> drivers/net/tlan.c:2614:6: warning: symbol 'TLan_PhyPowerUp' was not declared. Should it be static?
> drivers/net/tlan.c:2635:6: warning: symbol 'TLan_PhyReset' was not declared. Should it be static?
> drivers/net/tlan.c:2663:6: warning: symbol 'TLan_PhyStartLink' was not declared. Should it be static?
> drivers/net/tlan.c:2750:6: warning: symbol 'TLan_PhyFinishAutoNeg' was not declared. Should it be static?
> drivers/net/tlan.c:2906:5: warning: symbol 'TLan_MiiReadReg' was not declared. Should it be static?
> drivers/net/tlan.c:2996:6: warning: symbol 'TLan_MiiSendData' was not declared. Should it be static?
> drivers/net/tlan.c:3038:6: warning: symbol 'TLan_MiiSync' was not declared. Should it be static?
> drivers/net/tlan.c:3077:6: warning: symbol 'TLan_MiiWriteReg' was not declared. Should it be static?
> drivers/net/tlan.c:3147:6: warning: symbol 'TLan_EeSendStart' was not declared. Should it be static?
> drivers/net/tlan.c:3187:5: warning: symbol 'TLan_EeSendByte' was not declared. Should it be static?
> drivers/net/tlan.c:3248:6: warning: symbol 'TLan_EeReceiveByte' was not declared. Should it be static?
> drivers/net/tlan.c:3306:5: warning: symbol 'TLan_EeReadByte' was not declared. Should it be static?
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Kept the style consistent with the rest of the file, checkpatch will complain.
>  drivers/net/tlan.c |   64 ++++++++++++++++++++++++++--------------------------
>  1 files changed, 32 insertions(+), 32 deletions(-)

applied


