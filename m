From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skbuff:  don't corrupt mac_header on skb expansion
Date: Mon, 6 Jul 2009 11:23:14 -0700
Message-ID: <20090706112314.70078b19@nehalam>
References: <20090617151734.5ce02459@nehalam>
	<20090705035521.GA7693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052AbZGFSXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 14:23:16 -0400
In-Reply-To: <20090705035521.GA7693@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Jul 2009 11:55:21 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote:
> > The skb mac_header field is sometimes NULL (or ~0u) as a sentinel
> > value. The places where skb is expanded add an offset which would
> > change this flag into an invalid pointer (or offset).
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> What uses skb_mac_header_was_set apart from a debugging printk
> in route.c and nfnetlink_log (which is also essentially a debugging
> printk)?
> 
> This seems to be a bit much just to make a couple printks work?
> 
> What about using mac_len instead to figure out whether the MAC
> header is there?
> 
> Cheers,

No worries, either way works, I was just trying to keep acme's original code

-- 
