From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v3] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 09:54:05 +0100
Message-ID: <20120320085405.GG29891@secunet.com>
References: <20120320075846.GF29891@secunet.com>
 <1332232570-17424-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46663 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759537Ab2CTIyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 04:54:13 -0400
Content-Disposition: inline
In-Reply-To: <1332232570-17424-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 20, 2012 at 04:36:10PM +0800, Gao feng wrote:
> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
> This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent
> 
> Fix this by reserve headroom for dst_exthdrlen.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Thanks a lot!
