From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Thu, 02 Feb 2012 13:53:37 +0100
Message-ID: <1328187217.2279.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m34nv977x3.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yao zhao <yao.development@gmail.com>,
	Leonardo Uzcudun <uzcudunl@yahoo.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60174 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab2BBMxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 07:53:41 -0500
Received: by wgbdt10 with SMTP id dt10so2526483wgb.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 04:53:40 -0800 (PST)
In-Reply-To: <m34nv977x3.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 13:10 +0100, Benny Amorsen a =C3=A9=
crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > There is no ID reserved to untagged traffic in the 802.1Q specs, si=
nce
> > by definition, if traffic is untagged, there is _no_ VLAN tag in th=
e
> > frame.
>=20
> This is not entirely true. If you want to send 802.1p-tagged packets
> without a specific VLAN, you should use the 0 tag. I would say that
> comes quite close to "The ID reserved to untagged traffic is 0".
>=20
> It is, however, not 1.
>=20

There is a big confusion on the subject and terminology


_IF_ a 802.1Q Header is present in a frame, VID is a 12 bits field.
In the standard, only 0x000 and 0xFFF are reserved. Not 1.
On linux you can still use the full range, if you really want.

_IF_ no 802.1Q header is present, there is no VLAN id included in the
frame. This is what I called "Untagged"


To send a frame without 802.1Q header on linux, use the undelying
device, eth0.

Dont expect eth0.XXX to send a frame without 802.1Q header, since
eth0.XXX is _requested_ to send a 802.1Q header.
