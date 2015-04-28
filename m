From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [PATCH v4 1/3] ixgbe, ixgbevf: Add new mbox API to enable MC
 promiscuous mode
Date: Tue, 28 Apr 2015 19:36:40 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F8243E5@ORSMSX108.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EBE2@BPXM14GP.gisp.nec.co.jp>
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
	"Or Gerlitz" <gerlitz.or@gmail.com>,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EBE2@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.or=
g] On
> Behalf Of Hiroshi Shimamoto
> Sent: Thursday, April 09, 2015 6:04 PM
> To: Kirsher, Jeffrey T; Alexander Duyck; intel-wired-lan
> Cc: vyasevic@redhat.com; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; Choi, Sy Jong; linux-kernel@vger.kernel.org; =
David
> Laight; Hayato Momma; Edward Cree; Or Gerlitz; Bj=F8rn Mork
> Subject: [Intel-wired-lan] [PATCH v4 1/3] ixgbe, ixgbevf: Add new mbo=
x API to
> enable MC promiscuous mode
>=20
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> The limitation of the number of multicast address for VF is not enoug=
h for the
> large scale server with SR-IOV feature.
> IPv6 requires the multicast MAC address for each IP address to handle=
 the
> Neighbor Solicitation message.
> We couldn't assign over 30 IPv6 addresses to a single VF interface.
>=20
> The easy way to solve this is enabling multicast promiscuous mode.
> It is good to have a functionality to enable multicast promiscuous mo=
de for each
> VF from VF driver.
>=20
> This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> enable/disable multicast promiscuous mode in VF. If multicast promisc=
uous
> mode is enabled the VF can receive all multicast packets.
>=20
> With this patch, the ixgbevf driver automatically enable multicast pr=
omiscuous
> mode when the number of multicast addresses is over than 30 if possib=
le.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 76
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  2 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 27 +++++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  7 files changed, 111 insertions(+), 1 deletion(-)

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
