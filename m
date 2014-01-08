From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 00:06:17 -0800 (PST)
Message-ID: <1389168377.68061.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <20140107191436.GE30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35.bullet.mail.ne1.yahoo.com ([98.138.229.28]:35687 "HELO
	nm35.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755495AbaAHIJF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 03:09:05 -0500
In-Reply-To: <20140107191436.GE30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/7/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

> On Tue, Jan 07, 2014 at 02:57:27PM +0100, Francois-Xavier Le Bail wro=
te:
> > This change allows to follow a recommandation of RFC4942.
> >=20
> > - Add "anycast_src_echo_reply" sysctl to control the use of anycast=
 addresses
> >=A0=A0=A0as source addresses for ICMPv6 echo reply. This sysctl is f=
alse by default
> >=A0=A0=A0to preserve existing behavior.
> > - Add inline check ipv6_anycast_destination().
> > - Use them in icmpv6_echo_reply().
=20
> Works and best solution IMHO.

Yes. Thank you for testing.

BR
=46ran=E7ois-Xavier
=20
