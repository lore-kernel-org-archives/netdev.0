From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Mon, 17 Mar 2008 12:40:14 -0700
Message-ID: <20080317194014.GA7302@linuxace.com>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:57742
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753273AbYCQTkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:40:15 -0400
Content-Disposition: inline
In-Reply-To: <47DEADC4.4010609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 06:43:32PM +0100, Patrick McHardy wrote:
> Pavel Emelyanov wrote:
> > Can you check with this patch, please (untested, but should work)?
> 
> This is getting pretty ugly. Shouldn't
> 
> int ip_defrag(struct sk_buff *skb, u32 user)
> {
> ...
> -         net = skb->dev->nd_net;
> +         net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
> 
> work as well?

I can try either patch, but Patrick's looks simpler and thus perhaps
a better candidate this late in the -rc stage.

Pavel - you concur?

Phil
