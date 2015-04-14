From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Mon, 13 Apr 2015 23:07:14 -0700
Message-ID: <20150413230714.2cf40794@urahara>
References: <1428990724.6812.8.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com
To: Sebastian Poehn <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33605 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbbDNGHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 02:07:09 -0400
Received: by pdbnk13 with SMTP id nk13so132998333pdb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 23:07:08 -0700 (PDT)
In-Reply-To: <1428990724.6812.8.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2015 07:52:04 +0200
Sebastian Poehn <sebastian.poehn@gmail.com> wrote:

>  
> +	/* this should happen neither */
> +	if (unlikely(skb->sk))
> +		goto drop;
> +

With gcc, all goto's are already treated as unlikely().
