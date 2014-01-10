From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses for datagrams
Date: Fri, 10 Jan 2014 07:20:14 -0800 (PST)
Message-ID: <1389367214.89865.YahooMailBasic@web125503.mail.ne1.yahoo.com>
References: <1389275123-3305-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm49.bullet.mail.ne1.yahoo.com ([98.138.120.56]:36060 "HELO
	nm49.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753661AbaAJPXE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 10:23:04 -0500
In-Reply-To: <1389275123-3305-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1/9/14, Francois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

> This change allows to follow a recommandation of RFC4942.
> 
> - Add IPV6_ANYCAST_SRC_DGRAM socket option to control the use of anycast
>   addresses as source addresses for datagrams, with Advanced Sockets API
>   (RFC3542).
> - Add anycast_src_dgram sockopt flag.
> - Add ipv6_chk_acast_addr_src() to check if address is link-local on
>   given interface or is global on any interface.
> - Use them in ip6_datagram_send_ctl(), do_ipv6_setsockopt() and
>   do_ipv6_getsockopt()
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---

A v2 will be send soon.
