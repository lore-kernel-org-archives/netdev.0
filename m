From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 0/7] thunderbolt: Introducing Thunderbolt(TM)
 networking
Date: Tue, 19 Jul 2016 23:32:36 -0700
Message-ID: <1468996356.1900.96.camel@perches.com>
References: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
	 <1468948445.1900.53.camel@perches.com>
	 <E607265CB020454880711A6F96C05A03893D2493@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>,
	"andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <E607265CB020454880711A6F96C05A03893D2493@hasmsx107.ger.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-07-20 at 06:02 +0000, Levy, Amir (Jer) wrote:
> On Tue, Jul 19 2016, 08:14 PM, Joe Perches wrote:
> > On Mon, 2016-07-18 at 13:00 +0300, Amir Levy wrote:
> > >=20
> > > This is version 4 of Thunderbolt(TM) driver for non-Apple hardwar=
e.
> > []
> > > =A0Documentation/00-INDEX=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0|=A0=A0=A0=A02 +
> > > =A0Documentation/thunderbolt-networking.txt |=A0=A0135 ++
> > > =A0drivers/thunderbolt/Kconfig=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0|=A0=A0=A025 +-
> > > =A0drivers/thunderbolt/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0|=A0=A0=A0=A03 +-
> > > =A0drivers/thunderbolt/icm/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=
=A0=A028 +
> > > =A0drivers/thunderbolt/icm/icm_nhi.c=A0=A0=A0=A0=A0=A0=A0=A0| 164=
2 +++++++++++++++++++++
> > > =A0drivers/thunderbolt/icm/icm_nhi.h=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=
=A093 ++
> > > =A0drivers/thunderbolt/icm/net.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0| 2276 ++++++++++++++++++++++++++++++
> > > =A0drivers/thunderbolt/icm/net.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0|=A0=A0274 ++++
> > > =A0drivers/thunderbolt/nhi_regs.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
|=A0=A0115 +-
> > > =A010 files changed, 4585 insertions(+), 8 deletions(-)
> > > =A0create mode 100644 Documentation/thunderbolt-networking.txt
> > > =A0create mode 100644 drivers/thunderbolt/icm/Makefile
> > > =A0create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
> > > =A0create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
> > > =A0create mode 100644 drivers/thunderbolt/icm/net.c
> > > =A0create mode 100644 drivers/thunderbolt/icm/net.h
> > Is a MAINTAINERS update necessary or is Andreas going to be the
> > maintainer?
> Now that the drivers are completely separated it make sense that=A0
> I'll maintain the thunderbolt/icm driver,=A0=A0if there are no object=
ions.

I think that's fine and the MAINTAINERS file should have
a new section entry for this driver with your name too.
