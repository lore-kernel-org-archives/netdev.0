From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] drivers/net/bfin_mac.c: Use pr_fmt,
 netdev_<level>
Date: Tue, 27 Jul 2010 13:44:17 -0700
Message-ID: <20100727134417.62420ec1@nehalam>
References: <1280258531.24054.10.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280258531.24054.10.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2010 12:22:11 -0700
Joe Perches <joe@perches.com> wrote:

>  
> +static struct sk_buff *bfin_alloc_skb(void)
> +{
> +	/* allocate a new skb */
> +	struct sk_buff *new_skb = dev_alloc_skb(PKT_BUF_SIZE + NET_IP_ALIGN);
> +
> +	if (!new_skb)
> +		return NULL;
> +
> +	skb_reserve(new_skb, NET_IP_ALIGN);

Why not use netdev_alloc_skb_ip_align ?

-- 
