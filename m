From: <Mario.Limonciello@dell.com>
Subject: RE: [PATCH v8 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Fri, 21 Oct 2016 14:57:31 +0000
Message-ID: <4ae639fd83d643849eb1d12533e1f00e@ausx13mpc124.AMER.DELL.COM>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: <bhelgaas@google.com>, <corbet@lwn.net>,
        <linux-kernel@vger.kernel.org>, <linux-pci@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-doc@vger.kernel.org>,
        <thunderbolt-linux@intel.com>, <mika.westerberg@intel.com>,
        <tomas.winkler@intel.com>, <xiong.y.zhang@intel.com>
To: <amir.jer.levy@intel.com>, <gregkh@linuxfoundation.org>,
        <andreas.noever@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Amir Levy [mailto:amir.jer.levy@intel.com]
> Sent: Wednesday, September 28, 2016 9:44 AM
> To: gregkh@linuxfoundation.org
> Cc: andreas.noever@gmail.com; bhelgaas@google.com; corbet@lwn.net;
> linux-kernel@vger.kernel.org; linux-pci@vger.kernel.org;
> netdev@vger.kernel.org; linux-doc@vger.kernel.org; Limonciello, Mario
> <Mario_Limonciello@Dell.com>; thunderbolt-linux@intel.com;
> mika.westerberg@intel.com; tomas.winkler@intel.com;
> xiong.y.zhang@intel.com; Amir Levy <amir.jer.levy@intel.com>
> Subject: [PATCH v8 0/8] thunderbolt: Introducing Thunderbolt(TM)
> Networking
>=20
> This driver enables Thunderbolt Networking on non-Apple platforms
> running Linux.
>=20
> Thunderbolt Networking provides peer-to-peer connections to transfer
> files between computers, perform PC migrations, and/or set up small
> workgroups with shared storage.
>=20
> This is a virtual connection that emulates an Ethernet adapter that
> enables Ethernet networking with the benefit of Thunderbolt superfast
> medium capability.
>=20
> Thunderbolt Networking enables two hosts and several devices that
> have a Thunderbolt controller to be connected together in a linear
> (Daisy chain) series from a single port.
>=20
> Thunderbolt Networking for Linux is compatible with Thunderbolt
> Networking on systems running macOS or Windows and also supports
> Thunderbolt generation 2 and 3 controllers.
>=20
> Note that all pre-existing Thunderbolt generation 3 features, such as
> USB, Display and other Thunderbolt device connectivity will continue
> to function exactly as they did prior to enabling Thunderbolt Networking.
>=20
> Code and Software Specifications:
> This kernel code creates a virtual ethernet device for computer to
> computer communication over a Thunderbolt cable.
> The new driver is a separate driver to the existing Thunderbolt driver.
> It is designed to work on systems running Linux that
> interface with Intel Connection Manager (ICM) firmware based
> Thunderbolt controllers that support Thunderbolt Networking.
> The kernel code operates in coordination with the Thunderbolt user-
> space daemon to implement full Thunderbolt networking functionality.
>=20
> Hardware Specifications:
> Thunderbolt Hardware specs have not yet been published but are used
> where necessary for register definitions.
>=20
> Changes since v7:
>  - Removed debug prints
>  - Edited error prints
>  - Edited copyright notice
>  - Changed the Kconfig patch to be after the code changes
>=20
> These patches were pushed to GitHub where they can be reviewed more
> comfortably with green/red highlighting:
> 	https://github.com/01org/thunderbolt-software-kernel-tree
>=20
> Daemon code:
> 	https://github.com/01org/thunderbolt-software-daemon
>=20
> For reference, here's a link to version 6:
> [v7]:	https://lkml.org/lkml/2016/9/27/244
>=20
> Amir Levy (8):
>   thunderbolt: Macro rename
>   thunderbolt: Updating the register definitions
>   thunderbolt: Communication with the ICM (firmware)
>   thunderbolt: Networking state machine
>   thunderbolt: Networking transmit and receive
>   thunderbolt: Kconfig for Thunderbolt Networking
>   thunderbolt: Networking doc
>   thunderbolt: Adding maintainer entry
>=20
>  Documentation/00-INDEX                   |    2 +
>  Documentation/thunderbolt/networking.txt |  132 ++
>  MAINTAINERS                              |    8 +-
>  drivers/thunderbolt/Kconfig              |   27 +-
>  drivers/thunderbolt/Makefile             |    3 +-
>  drivers/thunderbolt/icm/Makefile         |    2 +
>  drivers/thunderbolt/icm/icm_nhi.c        | 1514 ++++++++++++++++++++
>  drivers/thunderbolt/icm/icm_nhi.h        |   82 ++
>  drivers/thunderbolt/icm/net.c            | 2254
> ++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/net.h            |  287 ++++
>  drivers/thunderbolt/nhi_regs.h           |  115 +-
>  11 files changed, 4417 insertions(+), 9 deletions(-)
>  create mode 100644 Documentation/thunderbolt/networking.txt
>  create mode 100644 drivers/thunderbolt/icm/Makefile
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
>  create mode 100644 drivers/thunderbolt/icm/net.c
>  create mode 100644 drivers/thunderbolt/icm/net.h
>=20
> --
> 2.7.4

Hi Amir,

I've tested your v8 series on Dell hardware with Thunderbolt=20
Controllers again between a Linux and Windows box.
Functionally it's working well.

Tested-By: Mario Limonciello <mario.limonciello@dell.com>

Andreas,

Following the history of this thread, I believe Greg was still looking for=
=20
an ack from you that Amir is using the interface properly.

Thanks,
