From: Ismail =?iso-8859-1?q?D=F6nmez?= <ismail@pardus.org.tr>
Subject: Re: Problem with commit a0ee18b9b7d3847976c6fb315c06a34fb296de0e
Date: Mon, 23 Apr 2007 22:09:09 +0300
Message-ID: <200704232209.10288.ismail@pardus.org.tr>
References: <200704231506.34410.ismail@pardus.org.tr> <20070423.115125.97295475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:57553 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754154AbXDWTHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 15:07:53 -0400
In-Reply-To: <20070423.115125.97295475.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
On Monday 23 April 2007 21:51:25 David Miller wrote:
> From: Ismail D=F6nmez <ismail@pardus.org.tr>
> Date: Mon, 23 Apr 2007 15:06:34 +0300
>
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -89,7 +89,7 @@ static const struct
> >  {
> >         int     error;
> >         u8      scope;
> > -} fib_props[RTA_MAX + 1] =3D {
> > +} fib_props[RTN_MAX + 1] =3D {
>
> This fix is already in the net-2.6.22 tree.

Yes I know the fix is in but I wondered why its creating such problems =
with=20
2.6.18 kernel, guess it depends on some other commits.

Regards,
ismail

--=20
Life is a game, and if you aren't in it to win,
what the heck are you still doing here?

-- Linus Torvalds (talking about open source development)
