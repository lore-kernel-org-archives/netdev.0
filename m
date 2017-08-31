From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to
 dccp_v6_do_rcv()
Date: Wed, 30 Aug 2017 22:16:49 -0700 (PDT)
Message-ID: <20170830.221649.818214075248119092.davem@davemloft.net>
References: <20170830090435.58406d1b@dev>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dccp@vger.kernel.org
To: tulup@mail.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830090435.58406d1b@dev>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrii Vladyka <tulup@mail.ru>
Date: Wed, 30 Aug 2017 09:04:35 +0300

> +	if (opt_skb) 
                    ^^^^

Trailing whitespace.

> @@ -653,6 +647,36 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
>  		__kfree_skb(opt_skb);
>  	kfree_skb(skb);
>  	return 0;
> +	
   ^^^^^^^

Likewise.
