From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 03/08] ipg: always compile in jumbo frame support
Date: Fri, 04 Jul 2008 08:48:57 -0400
Message-ID: <486E1C39.20308@garzik.org>
References: <Pine.LNX.4.64.0806231434510.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	Bircoph@list.ru, shemminger@vyatta.com, netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56340 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbYGDMtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:49:14 -0400
In-Reply-To: <Pine.LNX.4.64.0806231434510.23716@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka J Enberg wrote:
> From: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Add a ->is_jumbo boolean to struct ipg_nic_private and fix up
> ipg_interrupt_handler() to call the jumbo frame version of ipg_nic_rx() if the
> boolean is set to true. Also remove the JUMBO_FRAME #ifdefs so we can always
> compile in support for jumbo frames.
> 
> Tested-by: Andrew Savchenko <Bircoph@list.ru>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  drivers/net/ipg.c |   27 ++++++++++++++-------------
>  drivers/net/ipg.h |    9 +++++++--
>  2 files changed, 21 insertions(+), 15 deletions(-)

applied 3-8 to 2.6.27


