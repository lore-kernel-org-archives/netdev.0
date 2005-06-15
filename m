From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm PATCH][4/4] net: signed vs unsigned cleanup in
 net/ipv4/raw.c
Date: Wed, 15 Jun 2005 14:29:53 -0700 (PDT)
Message-ID: <20050615.142953.59469324.davem@davemloft.net>
References: <Pine.LNX.4.62.0506152316060.3842@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        ross.biro@gmail.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: juhl-lkml@dif.dk
In-Reply-To: <Pine.LNX.4.62.0506152316060.3842@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <juhl-lkml@dif.dk>
Date: Wed, 15 Jun 2005 23:32:22 +0200 (CEST)

> -	if (length >= sizeof(*iph) && iph->ihl * 4 <= length) {
> +	if (length >= sizeof(*iph) && (size_t)(iph->ihl * 4) <= length) {

Would changing the "4" into "4U" kill this warning just the same?

I think I'd prefer that.
