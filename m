From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix tunnel error handling
Date: Tue, 03 Nov 2015 10:52:47 -0500 (EST)
Message-ID: <20151103.105247.855059013530025317.davem@davemloft.net>
References: <20151103075107.9B08EA0CD2@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, miyazawa@linux-ipv6.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151103075107.9B08EA0CD2@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue,  3 Nov 2015 08:51:07 +0100 (CET)

> Both tunnel6_protocol and tunnel46_protocol share the same error
> handler, tunnel6_err(), which traverses through tunnel6_handlers list.
> For ipip6 tunnels, we need to traverse tunnel46_handlers as we do e.g.
> in tunnel46_rcv(). Current code can generate an ICMPv6 error message
> with an IPv4 packet embedded in it.
> 
> Fixes: 73d605d1abbd ("[IPSEC]: changing API of xfrm6_tunnel_register")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Good catch, applied and queued up for -stable.
