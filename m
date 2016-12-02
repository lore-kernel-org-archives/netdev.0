From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net] geneve: avoid use-after-free of skb->data
Date: Fri, 2 Dec 2016 13:33:01 -0500
Message-ID: <20161202183300.GA31657@tuxdriver.com>
References: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57062 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcLBSpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:45:13 -0500
Content-Disposition: inline
In-Reply-To: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 04:49:29PM +0100, Sabrina Dubroca wrote:
> geneve{,6}_build_skb can end up doing a pskb_expand_head(), which
> makes the ip_hdr(skb) reference we stashed earlier stale. Since it's
> only needed as an argument to ip_tunnel_ecn_encap(), move this
> directly in the function call.
> 
> Fixes: 08399efc6319 ("geneve: ensure ECN info is handled properly in all tx/rx paths")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Reviewed-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
