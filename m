From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] consolidate skb delivery
Date: Thu, 2 Oct 2003 21:25:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002192546.GA29673@wotan.suse.de>
References: <20031002102133.7285b5ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031002102133.7285b5ee.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +static __inline__ int deliver_skb(struct sk_buff *skb,
> +				  struct packet_type *pt_prev, int last)
> +{
> +	if (unlikely(!pt_prev->data))
> +		return deliver_to_old_ones(pt_prev, skb, last);

Are there even any old style protocols left? If not you could just make
it BUG() 

-Andi
