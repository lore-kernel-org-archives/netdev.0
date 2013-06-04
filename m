From: =?iso-8859-1?Q?Lambrecht_J=FCrgen?= <J.Lambrecht@TELEVIC.com>
Subject: Re: net: phy: Add config option to specify external switch port to
 be used if switch is used as PHY
Date: Tue, 4 Jun 2013 09:51:10 +0200
Message-ID: <51AD9C6E.9090302@televic.com>
References: <CABgrHxO6qzQQyokF3FvwyE_MywsdWmM-0JtxiXvK2qo6WU-JeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: rajkumar veer <rajkumar.veer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip2.televic.com ([81.82.194.222]:13112 "EHLO ip2.televic.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759638Ab3FDH4g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 03:56:36 -0400
In-Reply-To: <CABgrHxO6qzQQyokF3FvwyE_MywsdWmM-0JtxiXvK2qo6WU-JeQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 09:06 PM, rajkumar veer wrote:
> Hi  Jurgen,
>
> I am working on iMX6  FEC. Hw has  Marvel 88E6320 7-port switch=20
> instead of  a phy, which is connected  to CPU through RGMII via switc=
h=20
> Port 5.I am using the DSDT driver suit for marvell switch 88E6320.as=20
> you konw that this setup doesn't work after the FEC code was switch t=
o=20
> using phylib.
I had to google my own name to remember :-).
Can't you do as I did in my patch proposal, see=20
http://permalink.gmane.org/gmane.linux.kernel.embedded/3690 ?
>
> Could you please help me to find out that what are code modification=20
> is required for phy less fec driver to bypass phy detection/setup (ph=
y=20
> lib).
>
> Regards
>
> Raj
We use the fixed phy on our imx5 connected to a marvell switch, because=
=20
we do not always have an SMI bus connected to the switch:
drivers/net/phy/fixed.c
You could also try this.

Regards,
J=FCrgen

--=20
J=FCrgen Lambrecht
R&D Associate
Mobile: +32 499 644 531
Tel: +32 (0)51 303045    Fax: +32 (0)51 310670
http://www.televic-rail.com
Televic Rail NV - Leo Bekaertlaan 1 - 8870 Izegem - Belgium
Company number 0825.539.581 - RPR Kortrijk
