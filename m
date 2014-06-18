From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: net/hsr: not working :  High-availability Seamless Redundancy
 (HSRv0)
Date: Wed, 18 Jun 2014 18:00:52 +0200
Message-ID: <53A1B7B4.8010105@alten.se>
References: <5396FD42.1070100@kalkitech.in> <53972641.2070205@alten.se> <539EE434.7050901@kalkitech.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>
To: Gokul C G <gokul.g@kalkitech.in>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:58111 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbaFRQAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 12:00:30 -0400
In-Reply-To: <539EE434.7050901@kalkitech.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-06-16 14:33, Gokul C G wrote:
> Hi,
>=20
> PRP is protected by a number of patents. Does we need to  obtain
> license for those to make use of the patented technology and offer a
> PRP driver to end customers , if we use linux in embedded platform
> ??

I am not a patent expert, nor a lawyer, so I cannot advise you in this =
matter.
My understanding as a layman is that if there is a valid patent that co=
vers the
code, then yes, you need to obtain a license to be allowed to offer a p=
roduct
making use of the technology to end customers.


> I could find something like following while googling about HSR/PRP ,=20
> "In order to be compliant with the Linux open source licensing model,
> the Linux implementation of the PRP driver is in user space, not
> kernel space."  I couldn't understand the same !!

=46rom a patent perspective, I don't *think* it matters if the implemen=
tation is=20
in kernel space or user space; you'd need a license either way. By impl=
ementing=20
the driver in user space you don't have to make the source code availab=
le under=20
GPL, though. Again, I am not a lawyer, so don't take my word for it.


> whether Kernel implementation of HSR is problematic from a legal
> point of view (patent violation, see above for PRP) ??

Possibly. The HSRv0 standard cautions about patents regarding PRP (the =
PRP=20
duplicate discard algorithm, using a Redundancy Control Trailer) and in=
teractions
between HSR and PRP nets. HSR does not use a Redundancy Control Trailer=
=2E

The HSRv1 standard also cautions about patent claims for interconnectin=
g HSR nets
though QuadBoxes, and additional PRP patents.=20

I have no idea if these claims are valid, and I don't know if these are=
 the only=20
parts of the standard which may be patent encumbered.=20

=46rom the standard: "ISO (www.iso.org/patents) and IEC (http://patents=
=2Eiec.ch)=20
maintain on-line data bases of patents relevant to their standards. Use=
rs are=20
encouraged to consult the data bases for the most up to date informatio=
n=20
concerning patents."


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
