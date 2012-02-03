From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Fri, 03 Feb 2012 16:43:13 +0100
Message-ID: <1328283793.2157.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	 <1328219828.2480.32.camel@edumazet-laptop>
	 <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	 <1328222744.2480.38.camel@edumazet-laptop>
	 <CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
	 <1328263278.2157.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEU2+vrMKjLXyABZhi5QrUBA=Fvd4ExgMxjD+T376AZW1SRd8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:41724 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668Ab2BCPnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:43:17 -0500
Received: by wics10 with SMTP id s10so2702767wic.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:43:16 -0800 (PST)
In-Reply-To: <CAEU2+vrMKjLXyABZhi5QrUBA=Fvd4ExgMxjD+T376AZW1SRd8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 08:21 -0700, Erich E. Hoover a =
=C3=A9crit :
> On Fri, Feb 3, 2012 at 3:01 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > ...
> > BTW, do we really want the htonl() thing, and force device indexes =
in
> > 2^24 range ? This seems odd anyway.
> > ...
>=20
> I can easily perform both of these steps in Wine.  The 2^24 limitatio=
n
> in particular seems artificial, and especially silly to add to the
> kernel if it will change the fundamental range of the indices.  With
> regard to htonl(), David Miller indicated that the API should match
> what other systems use (a 32-bit network byte order word), though he
> may not have meant his comment that specifically.  I can see the
> merits of doing it both ways and I'm not particularly attached to
> either one.

I have no strong feeling, I only wanted to point out our current device
indexes range is [1 .. (2^31 - 1) ]
