From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] dts: Add a binding for Synopsys emac max-frame-size
Date: Tue, 14 Jan 2014 08:07:38 -0800
Message-ID: <1890114.hPeOerbe4b@lenovo>
References: <1389710409-14106-1-git-send-email-vbridgers2013@gmail.com> <1389710409-14106-2-git-send-email-vbridgers2013@gmail.com> <1389715056.10673.9.camel@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rayagond@vayavyalabs.com
To: Dinh Nguyen <dinguyen@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55901 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbaANQHt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:07:49 -0500
In-Reply-To: <1389715056.10673.9.camel@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 janvier 2014, 09:57:36 Dinh Nguyen a =E9crit :
> On Tue, 2014-01-14 at 08:40 -0600, Vince Bridgers wrote:
> > This change adds a parameter for the Synopsys 10/100/1000
> > stmmac Ethernet driver to configure the maximum frame
> > size supported by the EMAC driver. Synopsys allows the FIFO
> > sizes to be configured when the cores are built for a particular
> > device, but do not provide a way for the driver to read
> > information from the device about the maximum MTU size
> > supported as limited by the device's FIFO size.
> >=20
> > Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> > ---
> >=20
> >  Documentation/devicetree/bindings/net/stmmac.txt |    5 +++++
> >  1 file changed, 5 insertions(+)
> >=20
> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
> > b/Documentation/devicetree/bindings/net/stmmac.txt index eba0e5e..2=
6a0ba9
> > 100644
> > --- a/Documentation/devicetree/bindings/net/stmmac.txt
> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> >=20
> > @@ -30,6 +30,10 @@ Required properties:
> >  Optional properties:
> >  - mac-address: 6 bytes, mac address
> >=20
> > +- snps,max-frame-size:	Maximum frame size permitted. This paramete=
r is
> > useful
> I don't think max-frame-size should be a snps-only binding.

Right, and I already made that comment to Vince. Maybe this is just an=20
oversight and mistakenly resubmitted v2 instead of v3?
--=20
=46lorian
