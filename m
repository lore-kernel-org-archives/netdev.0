From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 7/9] tproxy: added IPv6 support to the TPROXY target
Date: Thu, 21 Oct 2010 10:47:08 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010211042190.22922@obet.zrqbmnf.qr>
References: <20101020112118.6260.31618.stgit@este.odu> <20101020112118.6260.51773.stgit@este.odu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101020112118.6260.51773.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> 
> /* TPROXY target is capable of marking the packet to perform
>  * redirection. We can get rid of that whenever we get support for
>  * mutliple targets in the same rule. */
>-struct xt_tproxy_target_info {
>+struct xt_tproxy_target_info_v0 {
> 	u_int32_t mark_mask;
> 	u_int32_t mark_value;
> 	__be32 laddr;
> 	__be16 lport;
> };

You cannot change the struct name either, or it may break userspace
compilations.

