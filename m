From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Initialize ip6_tnl.hlen in gre tunnel even if no route is found
Date: Fri, 11 Oct 2013 17:02:17 +0200
Message-ID: <20131011150216.GA18601@order.stressinduktion.org>
References: <1381427427-14880-1-git-send-email-ou.ghorbel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oussama Ghorbel <ou.ghorbel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381427427-14880-1-git-send-email-ou.ghorbel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 06:50:27PM +0100, Oussama Ghorbel wrote:
> The ip6_tnl.hlen (gre and ipv6 headers length) is independent from the
> outgoing interface, so it would be better to initialize it even when no
> route is found, otherwise its value will be zero.
> While I'm not sure if this could happen in real life, but doing that
> will avoid to call the skb_push function with a zero in ip6gre_header
> function.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
