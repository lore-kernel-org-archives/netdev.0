From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] net: Add __dev_forward_skb
Date: Mon, 7 Apr 2014 11:48:54 -0700
Message-ID: <20140407114854.135e2e6c@nehalam.linuxnetplumber.net>
References: <<20140407075347.GA26461@gondor.apana.org.au>
	<E1WX4P1-0006vx-NF@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:59953 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755688AbaDGSs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 14:48:58 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so7118451pbc.21
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 11:48:57 -0700 (PDT)
In-Reply-To: <E1WX4P1-0006vx-NF@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Apr 2014 15:55:35 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> +}
> +EXPORT_SYMBOL_GPL(__dev_forward_skb);
> +

Don't export a symbol without a followup patch that uses it.
