From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC] CAIF Protocol Stack
Date: Fri, 18 Sep 2009 15:38:50 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902DF9765@eseldmw101.eemea.ericsson.se>
References: <61D8D34BB13CFE408D154529C120E07902DF9076@eseldmw101.eemea.ericsson.se> <0f510ae3e0a78a2c1345d8e08bdafb0e@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?iso-8859-1?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:63716 "EHLO
	mailgw3.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbZIRNit convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 09:38:49 -0400
Content-class: urn:content-classes:message
In-Reply-To: <0f510ae3e0a78a2c1345d8e08bdafb0e@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: R=E9mi Denis-Courmont
> Sent: 18. september 2009 14:32
>     Hello,
>=20
> On Wed, 16 Sep 2009 14:30:34 +0200, Sjur Br=E6ndeland=20
> <sjur.brandeland@stericsson.com> wrote:
> > The Implementation of CAIF is divided into:
> > * CAIF Devices: Character Device, Net Device and Kernel API.
> > * CAIF Protocol Implementation
> > * CAIF Link Layer
>=20
> I'm a bit confused here. What do you call a CAIF Device?
>=20
> Do you mean a GPRS context is a network device, and an AT=20
> command interface is a character device? Or is the CAIF modem=20
> a device? or what?

What I meant was:
* "Net Device" - a "struct net_device" with one instance for each GPRS =
PDP context.
* "Character Device" - a chr device, with one instance for each AT chan=
nel towards the modem.

BR/Sjur Br=E6ndeland
