From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix select() for SOCK_RAW sockets (ipv6)
Date: Tue, 7 Dec 2004 10:48:15 -0800
Message-ID: <20041207104815.3f7a4684.davem@davemloft.net>
References: <20041207045302.GA23746@linuxace.com>
	<20041207054840.GD61527@gaz.sfgoth.com>
	<20041207150834.GA75700@gaz.sfgoth.com>
	<20041208.023530.26430801.yoshfuji@linux-ipv6.org>
	<20041207100140.781f4c00@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, mitch@sfgoth.com, kernel@linuxace.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041207100140.781f4c00@dxpl.pdx.osdl.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Dec 2004 10:01:40 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> > Probably, we need to do the same for ipv6, don't we?
> 
> diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> --- a/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
> +++ b/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
> @@ -513,6 +513,27 @@

We didn't do the "UDP select() fix" on ipv6 because we don't
have the delayed checksumming optimization there.  So the
ipv6 side really doesn't need this change.

Or did I miss something?
