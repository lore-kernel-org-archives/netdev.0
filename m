From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 0/7] thunderbolt: Introducing Thunderbolt(TM)
 networking
Date: Tue, 19 Jul 2016 10:14:05 -0700
Message-ID: <1468948445.1900.53.camel@perches.com>
References: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>, andreas.noever@gmail.com,
	gregkh@linuxfoundation.org, bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-07-18 at 13:00 +0300, Amir Levy wrote:
> This is version 4 of Thunderbolt(TM) driver for non-Apple hardware.
[]
> =A0Documentation/00-INDEX=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0|=A0=A0=A0=A02 +
> =A0Documentation/thunderbolt-networking.txt |=A0=A0135 ++
> =A0drivers/thunderbolt/Kconfig=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0|=A0=A0=A025 +-
> =A0drivers/thunderbolt/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
|=A0=A0=A0=A03 +-
> =A0drivers/thunderbolt/icm/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=
=A028 +
> =A0drivers/thunderbolt/icm/icm_nhi.c=A0=A0=A0=A0=A0=A0=A0=A0| 1642 ++=
+++++++++++++++++++
> =A0drivers/thunderbolt/icm/icm_nhi.h=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A0=
93 ++
> =A0drivers/thunderbolt/icm/net.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=
 2276 ++++++++++++++++++++++++++++++
> =A0drivers/thunderbolt/icm/net.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=
=A0=A0274 ++++
> =A0drivers/thunderbolt/nhi_regs.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=
=A0115 +-
> =A010 files changed, 4585 insertions(+), 8 deletions(-)
> =A0create mode 100644 Documentation/thunderbolt-networking.txt
> =A0create mode 100644 drivers/thunderbolt/icm/Makefile
> =A0create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
> =A0create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
> =A0create mode 100644 drivers/thunderbolt/icm/net.c
> =A0create mode 100644 drivers/thunderbolt/icm/net.h

Is a MAINTAINERS update necessary or is Andreas going to
be the maintainer?
