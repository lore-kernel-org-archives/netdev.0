From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
Date: Fri, 9 Nov 2007 19:12:02 +0100
Message-ID: <200711091912.03419.netdev@axxeo.de>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com> <20071108.044745.123583545.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:2732 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbXKISMX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 13:12:23 -0500
In-Reply-To: <20071108.044745.123583545.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E schrieb:
> In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.no=
s.boeing.com> (at Wed, 7 Nov 2007 10:52:47 -0800), "Templin, Fred L" <F=
red.L.Templin@boeing.com> says:
>=20
> > > > > > > +	if (((ipv4 >=3D 0x01000000) && (ipv4 < 0x0a000000)) ||
> > > > > > > +	    ((ipv4 >=3D 0x0b000000) && (ipv4 < 0x7f000000)) ||
> > > > > > > +	    ((ipv4 >=3D 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> > > > > > > +	    ((ipv4 >=3D 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> > > > > > > +	    ((ipv4 >=3D 0xac200000) && (ipv4 < 0xc0a80000)) ||
> > > > > > > +	    ((ipv4 >=3D 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> > > > > > > +	    ((ipv4 >=3D 0xc6140000) && (ipv4 <=20
> > > 0xe0000000))) eui[0] |=3D
> > > > > > > 0x2;
>=20
> > Maybe it is I who did not understand. Can you suggest a clean solut=
ion?
>=20
> You could write each element as LOOPBACK(), MULTICAST()
> etc.
> 	eui[0] =3D (!ZERONETO(a) &&
> 	          !PRIVATE_10(a) &&
> 		  !LINKLOCAL(a) &&
> 		  !PRIVATE_172(a) &&
> 		  !PRIVATE_192(a) &&
> 		  !NETICDEVBENCH(a) &&
> 		  !MULTICAST(a)) ? 2 : 0;

Oh, yes that's great! Now even *I* can read what this is all about=20
without reading any RFC :-)

Please Fred, try to do it that way.


Best Regards

Ingo Oeser
