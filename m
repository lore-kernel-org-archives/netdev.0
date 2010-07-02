From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix a dst leak in ipv6 REJECT
Date: Fri, 02 Jul 2010 10:07:08 +0200
Message-ID: <4C2D9E2C.8030607@trash.net>
References: <1278054411.2597.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278054411.2597.13.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> We should release dst if dst->error is set.
>
> Bug introduced in 2.6.14 by commit e104411b82f5c
> ([XFRM]: Always release dst_entry on error in xfrm_lookup)
>   

Applied, thanks Eric.
