From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: dsa: b53: constify xfrm_replay structures
Date: Tue, 9 Aug 2016 19:27:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1608091927070.2911@hadrien>
References: <1470761889-26808-1-git-send-email-Julia.Lawall@lip6.fr> <4a13be00-d6ac-2c40-b7a6-1436072d36b8@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4a13be00-d6ac-2c40-b7a6-1436072d36b8@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 9 Aug 2016, Florian Fainelli wrote:

> On 08/09/2016 09:58 AM, Julia Lawall wrote:
> > The xfrm_replay structures are never modified, so declare them as const.
>
> You mean b53_io_ops here, right?

Oops.  I sent a v2.

julia

> Other than that LTGM, but this will
> have to wait for "net"next to re_open since this is more of a cleanup
> than bugfix. Thanks!
> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
