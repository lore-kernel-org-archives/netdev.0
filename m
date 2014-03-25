From: Simon =?UTF-8?B?S8OlZ3N0csO2bQ==?= <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH RFC] ixp4xx_eth: Allow setting the MDIO bus name in
 platform data
Date: Tue, 25 Mar 2014 12:37:39 +0100
Message-ID: <20140325123739.05017fcf@marrow.netinsight.se>
References: <20140324151729.1b8e3bb5@marrow.netinsight.se>
	<m3r45r72u9.fsf@intrepid.localdomain>
	<CAGVrzcaJ5LKE_HAvsmbnFxYsLbNwi9h9UYrz60AQ3z4DOZKwYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	"arm@kernel.org" <arm@kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:62707 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753032AbaCYLhs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 07:37:48 -0400
In-Reply-To: <CAGVrzcaJ5LKE_HAvsmbnFxYsLbNwi9h9UYrz60AQ3z4DOZKwYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Mar 2014 13:42:29 -0700
=46lorian Fainelli <f.fainelli@gmail.com> wrote:

> 2014-03-24 13:34 GMT-07:00 Krzysztof Halasa <khc@pm.waw.pl>:
> > Simon K=C3=A5gstr=C3=B6m <simon.kagstrom@netinsight.net> writes:
> >
> >> Allows using e.g., a fixed MDIO bus with the ixp4xx_eth driver.
> >> Example:
> >
> >
> > Why do we need it? I'm not sure I know what constitutes a "fixed MD=
IO
> > bus".
>=20
> This is a software emulation MDIO bus for when your Ethernet MAC is
> connected to a PHY which does not appear on the MDIO bus. This is
> typically used to provide the Ethernet driver with a link that is
> always seen as UP, when you cannot directly query it via MDIO/MDC.

Yes, exactly. We have a board which uses two of the ipx4xx NPE:s, one
which uses a real PHY via the ixp4xx_eth MDIO bus and one which uses
the fixed PHY driver.

To support this, we need this patch as the driver would otherwise
always look for the PHY on the ixp4xx_eth MDIO bus.

// Simon
