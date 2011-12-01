From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Wed, 30 Nov 2011 18:27:53 -0800
Message-ID: <20111130182753.02798425@nehalam.linuxnetplumber.net>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	<CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60524 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979Ab1LAC14 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 21:27:56 -0500
In-Reply-To: <CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2011 18:11:32 -0800
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> > Why make it an option? TOS should always be set to interactive
> > traffic (like telnet and slogin)
>=20
> Because 'interactive' doesn't mean anything.  You don't know what
> value of tos defines 'interactive' traffic on my network.
> I may also consider network console/debug/dump/etc traffic less
> important then say serving web traffic, and thus not even want it to
> be considered 'interactive' in the first place.
>=20
> TOS values are relevant within a LAN/WAN/Organization/AS, but are not
> relevant internet-wide.
> Almost all AS-boundary gateways/routers will do TOS remarking to thei=
r
> own internal specifications.
>=20
> - Maciej

Giving the user choice in general is good, but network configuration
is already confusing enough.

Although interpretation of TOS is per organization, in practice the
values are standardized in places like RFC4594. For example, routing pr=
otocols
all use IPTOS_PREC_INTERNETCONTROL =3D 0xc0
