From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: Re: [PATCH v4 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Tue, 28 Apr 2015 19:37:32 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F82443D@ORSMSX108.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EC5C@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Gerlitz <gerlitz.or@gmail.com>, David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>, Or,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EC5C@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Hiroshi Shimamoto
> Sent: Thursday, April 09, 2015 6:08 PM
> To: Kirsher, Jeffrey T; Alexander Duyck; intel-wired-lan
> Cc: vyasevic@redhat.com; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; Choi, Sy Jong; linux-kernel@vger.kernel.org; David
> Laight; Hayato Momma; Edward Cree; Or Gerlitz; Bj=F8rn Mork
> Subject: [Intel-wired-lan] [PATCH v4 3/3] ixgbe: Add new ndo to allow VF
> multicast promiscuous mode
> =

> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> =

> Implements the new netdev op to allow VF multicast promiscuous mode.
> =

> The multicast promiscuous mode is not allowed for all VFs by default.
> =

> The administrator can allow to VF multicast promiscuous mode for only tru=
sted
> VM. After allowing multicast promiscuous mode from the host, we can use o=
ver
> 30 IPv6 addresses on VM.
>  # ip link set dev eth0 vf 1 mc_promisc on
> =

> When disallowing multicast promiscuous mode, ixgbevf can only handle 30
> IPv6 addresses at most.
>  # ip link set dev eth0 vf 1 mc_promisc off
> =

> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
> =

> v4: Put reconfiguration of MC promiscuous mode into the previous loop.
> =

>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  5 ++++
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32
> ++++++++++++++++++++++++--  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.=
h |
> 2 ++
>  4 files changed, 38 insertions(+), 2 deletions(-)

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>

---------------------------------------------------------------------------=
---
One dashboard for servers and applications across Physical-Virtual-Cloud =

Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
