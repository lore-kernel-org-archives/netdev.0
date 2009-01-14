From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 10/34]bnx2x: Compilation issue on IA64
Date: Wed, 14 Jan 2009 19:44:33 +0200
Message-ID: <1231955073.11301.161.camel@lb-tlvb-eliezer>
References: <1231951391.11301.131.camel@lb-tlvb-eliezer>
 <1231952824.3010.29.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3917 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbZANRpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 12:45:45 -0500
In-Reply-To: <1231952824.3010.29.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 09:07 -0800, Ben Hutchings wrote:
> On Wed, 2009-01-14 at 18:43 +0200, Eilon Greenstein wrote:
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
[...]  
> >  #ifdef BNX2X_STOP_ON_ERROR
> >  	fp->tpa_queue_used |= (1 << queue);
> > -#ifdef __powerpc64__
> > +#if (defined __powerpc64__) || (defined _ASM_IA64_TYPES_H)
> >  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
> >  #else
> >  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
> 
> Or you could cast the value to unsigned long long and remove this
> fragile #ifdef.
> 
You are right - it is a better solution. The issue is that this uglier
solution is already in, and I hate to re-send this patch just for this.
Can we have this one applied and I will re visit it in net-next?

Eilon


