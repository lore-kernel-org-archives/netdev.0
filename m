From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Tue, 20 Apr 2010 01:18:38 -0700 (PDT)
Message-ID: <20100420.011838.209999791.davem@davemloft.net>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com>
	<68CA249E-C6E9-43EA-A132-C48DB9E2384D@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566Ab0DTISd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 04:18:33 -0400
In-Reply-To: <68CA249E-C6E9-43EA-A132-C48DB9E2384D@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Mon, 19 Apr 2010 23:44:49 -0500

> 
> On Apr 18, 2010, at 6:13 PM, Andy Fleming wrote:
> 
>> When gracefully stopping the controller, the driver was continuing if
>> *either* RX or TX had stopped.  We need to wait for both, or the
>> controller could get into an invalid state.
>> 
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> ---
>> drivers/net/gianfar.c |    5 +++--
>> 1 files changed, 3 insertions(+), 2 deletions(-)
> 
> Acked-by: Kumar Gala <galak@kernel.crashing.org>
> 
> (please pick this up for 2.6.34, fixes an annoying bug).

I will do this tomorrow, thanks!
