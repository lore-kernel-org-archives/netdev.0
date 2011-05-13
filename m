From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 22:00:44 +0200
Message-ID: <1305316844.3120.8.camel@edumazet-laptop>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	 <1304995124.4065.157.camel@localhost> <20110510043833.GG6397@morgul.net>
	 <1305031369.4065.259.camel@localhost> <20110510180540.GI6397@morgul.net>
	 <20110510151100.52a9f8fa@nehalam> <20110510233540.GJ6397@morgul.net>
	 <20110513125314.66861b31@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Noah Meyerhans <noahm@debian.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40433 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214Ab1EMUAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:00:50 -0400
Received: by wya21 with SMTP id 21so2159300wya.19
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 13:00:49 -0700 (PDT)
In-Reply-To: <20110513125314.66861b31@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 mai 2011 =C3=A0 12:53 -0700, Stephen Hemminger a =C3=A9c=
rit :
> The commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e
>     bridge: Reset IPCB when entering IP stack on NF_FORWARD
> broke forwarding of IPV6 packets in bridge because it would
> call bp_parse_ip_options with an IPV6 packet.
>=20
> Reported-by: Noah Meyerhans <noahm@debian.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> Patch against net-next-2.6 but must be applied to net-2.6
> and stable as well
>=20

Well, stable is not needed, since faulty commit is not in 2.6.38

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>



