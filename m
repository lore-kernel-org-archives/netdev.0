From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: IPv6: Bug in net-next
Date: Wed, 8 Jan 2014 05:35:39 -0800 (PST)
Message-ID: <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm43.bullet.mail.ne1.yahoo.com ([98.138.120.50]:41728 "HELO
	nm43.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752039AbaAHNih convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 08:38:37 -0500
In-Reply-To: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1/8/14, Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

> > I think there is a bug in actual net-next.
 =20
> > When I execute this code and press Crtl-C, all the IPv6
> > Link-Layer addresses are deleted.
 =20
> > This happened between
> > c1ddf295f5183a5189196a8035546842caa2055a and HEAD.
 =20
> > [...]
=20
> Sorry, it is not linked to this code.
> I'm looking for the reason ...
=20
It seems that the valid lifetime and preferred lft are set to 0 sec for=
 autoconfigured LLA.

 BR,
 Francois-Xavier
