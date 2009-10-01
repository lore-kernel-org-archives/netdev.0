From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] IPv4 TCP fails to send window scale option when window
 scale is zero
Date: Thu, 01 Oct 2009 16:30:54 +0200
Message-ID: <4AC4BD1E.6060706@gmail.com>
References: <4AC478E9.5050605@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Ori Finkalman <ori@comsleep.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46692 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232AbZJAOa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 10:30:59 -0400
In-Reply-To: <4AC478E9.5050605@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> From: Ori Finkelman <ori@comsleep.com>
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5200aab..fcd278a 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -361,6 +361,7 @@ static inline int tcp_urg_mode(const struct tcp_s=
ock
> *tp)
> #define OPTION_SACK_ADVERTISE  (1 << 0)
> #define OPTION_TS              (1 << 1)
> #define OPTION_MD5             (1 << 2)
> +#define OPTION_WSCALE          (1 << 3)

I manually applied your patch and tested it.

So far so good, it works well.

But you'll need to find correct way to submit a patch so that your mail=
er doesnt
mangle the content.

=46ile Documentation/email-clients.txt contains useful tips.

