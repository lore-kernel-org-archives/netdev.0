From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 5/9] tproxy: allow non-local binds of IPv6 sockets
 if IP_TRANSPARENT is enabled
Date: Thu, 21 Oct 2010 16:11:26 +0200
Message-ID: <4CC04A0E.4030203@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu> <20101021104709.5192.12412.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021104709.5192.12412.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.10.2010 12:47, schrieb KOVACS Krisztian:
> @@ -343,7 +343,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			 */
>  			v4addr = LOOPBACK4_IPV6;
>  			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
> -				if (!ipv6_chk_addr(net, &addr->sin6_addr,
> +				if (!inet->transparent && !ipv6_chk_addr(net, &addr->sin6_addr,
>  						   dev, 0)) {

This looked like it was supposed to have a line break at the &&, so I've
added that and applied it.
