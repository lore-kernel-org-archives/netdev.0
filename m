From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC PATCH v3  5/8] CAIF Protocol Stack
Date: Thu, 10 Dec 2009 08:44:37 -0800
Message-ID: <20091210084437.cc38367c.randy.dunlap@oracle.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
	<1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
	<1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
	<1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
	<1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
	<1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
	<4B13F5D3.6090009@oracle.com>
	<61D8D34BB13CFE408D154529C120E0790311F113@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <stefano.babic@babic.homelinux.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:55372 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760801AbZLJQqI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 11:46:08 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E0790311F113@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Dec 2009 14:05:13 +0100 Sjur Br=E6ndeland wrote:

> Randy Dunlap wrote:
> > sjur.brandeland@stericsson.com wrote:
> >> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> >=20
> > what Patrick said:
> > patch description should be here and each email subject should be
> > different and describe what that patch does. Please read
> > Documentation/SubmittingPatches.=20
> OK I'll read carefully through Submitting Patches. Do you recon this =
will be ok?
> Subject: [PATCH X/Y] net-caif: Add CAIF Protocol Stack in net/caif/ge=
neric

One big point is that the subject line shouldn't be the same
for all of the patches (disregarding PATCH X/Y).
They should be like (e.g.):

[PATCH 1/5] net-caif: add header files
[PATCH 2/5] net-caif: add caif protocol
[PATCH 3/5] net-caif: add caif devices
[PATCH 4/5] net-caif: documentation
[PATCH 5/5] net-caif: Kconfig and Makefile




> >> +menuconfig CAIF
> >> +	tristate "Enable CAIF support"
> >> +	default n
> >> +	---help---
> >=20
> > Tell us what CAIF means, probably in the help text.
>=20
> I have rephrased this a bit, what do you think about this:
> [snip]
> menuconfig CAIF
> 	tristate "Enable CAIF support"
> 	default n
> 	---help---
> 	The "Communication CPU to Application CPU Interface" (CAIF) is a pac=
ket based
> 	connection-oriented MUX protocol developed by ST-Ericsson for use wi=
th its modems.
>=20
> 	Say Y (or M) here if you build for a phone product (e.g. Android) th=
at uses
> 	CAIF as transport, if unsure say N.=20
>=20
> 	If you select to build it as module then CAIF_SOCK and CAIF_NETDEV a=
lso needs to=20
> 	be built as modules. You will also need to say yes to any CAIF physi=
cal devices that
> 	your platform requires.
>=20
> 	See Documentation/net/CAIF for a further explanation on how to use a=
nd configure CAIF.


That looks good, thanks.

---
~Randy
