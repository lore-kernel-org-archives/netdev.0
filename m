From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Mon, 29 Sep 2008 11:46:50 +0200
Message-ID: <20080929094650.GA26097@xi.wantstofly.org>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org> <20080929053931.GB21663@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44107 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbYI2Jqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 05:46:54 -0400
Content-Disposition: inline
In-Reply-To: <20080929053931.GB21663@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 09:39:31AM +0400, Evgeniy Polyakov wrote:

> Hi Lennert.

Hi Evgeniy,


> > Doesn't it?  It calls skb_release_head_state() (new function), which
> > should do that.
> 
> Argh, you are right, I missed this hunk:
> -/* Free everything but the sk_buff shell. */
> -static void skb_release_all(struct sk_buff *skb)
> +static void skb_release_head_state(struct sk_buff *skb) 
> 
> Patches look good.

Cool, thanks for having a look.

Could you (or anyone else) try this patch on one of your boxes and
see what kind of effect it has on performance?


cheers,
Lennert
