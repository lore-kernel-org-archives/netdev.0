From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6.0-test8/9] ethertap oops
Date: Sun, 26 Oct 2003 23:48:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026234828.2cb1f746.davem@redhat.com>
References: <L1fo.3gb.9@gated-at.bofh.it>
	<m3ekwz7h3z.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: simon.roscic@chello.at, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3ekwz7h3z.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 26 Oct 2003 23:45:52 +0100
Andi Kleen <ak@muc.de> wrote:

> diff -u linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o linux-2.6.0test7mm1-averell/drivers/net/ethertap.c
> --- linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o	2003-09-11 04:12:33.000000000 +0200
> +++ linux-2.6.0test7mm1-averell/drivers/net/ethertap.c	2003-10-26 23:41:17.000000000 +0100

This part looks good, applied.

> diff -u linux-2.6.0test7mm1-averell/net/netlink/af_netlink.c-o linux-2.6.0test7mm1-averell/net/netlink/af_netlink.c
> --- linux-2.6.0test7mm1-averell/net/netlink/af_netlink.c-o	2003-10-09 00:29:02.000000000 +0200
> +++ linux-2.6.0test7mm1-averell/net/netlink/af_netlink.c	2003-10-26 23:42:44.000000000 +0100
> @@ -777,6 +777,7 @@
>  	if (input)
>  		nlk_sk(sk)->data_ready = input;
>  
> +	sk->sk_protocol = unit;
>  	netlink_insert(sk, 0);
>  	return sk;
>  }

This part is not needed, netlink_create() does this for us :-)

Thanks Andi.
