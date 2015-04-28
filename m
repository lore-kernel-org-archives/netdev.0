From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v4 2/3] if_link: Add VF multicast
	promiscuous control
Date: Tue, 28 Apr 2015 19:37:08 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F82441E@ORSMSX108.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EC0A@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EC0A@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.or=
g] On
> Behalf Of Hiroshi Shimamoto
> Sent: Thursday, April 09, 2015 6:05 PM
> To: Kirsher, Jeffrey T; Alexander Duyck; intel-wired-lan
> Cc: vyasevic@redhat.com; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; Choi, Sy Jong; linux-kernel@vger.kernel.org; =
David
> Laight; Hayato Momma; Edward Cree; Or Gerlitz; Bj=F8rn Mork
> Subject: [Intel-wired-lan] [PATCH v4 2/3] if_link: Add VF multicast p=
romiscuous
> control
>=20
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Add netlink directives and ndo entry to allow VF multicast promiscuou=
s mode.
>=20
> This controls the permission to enter VF multicast promiscuous mode.
> The administrator will dedicatedly allow multicast promiscuous per VF=
=2E
>=20
> When the VF is under multicast promiscuous mode, all multicast packet=
s are sent
> to the VF.
>=20
> Don't allow VF multicast promiscuous if the VM isn't fully trusted.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 19 +++++++++++++++++--
>  4 files changed, 27 insertions(+), 2 deletions(-)

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
