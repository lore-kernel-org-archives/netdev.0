From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 3/3] ixgbe: Add new ndo to allow VF multicast
 promiscuous mode
Date: Fri, 20 Feb 2015 09:50:54 +0200
Message-ID: <CAJ3xEMj5GZgtJA2tkBq1E9QD4SOmsgOzYyWuc=YJ_wdewKt6hg@mail.gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 20, 2015 at 3:01 AM, Hiroshi Shimamoto
<h-shimamoto@ct.jp.nec.com> wrote:

> The administrator can allow to VF multicast promiscuous mode for only
> trusted VM.
>  # ./ip link set dev eth0 vf 1 mc_promisc on
> When disallowing multicast promiscuous mode, we can only use 30 IPv6 addresses.
>  # ./ip link set dev eth0 vf 1 mc_promisc off

all the above text belongs to the change-log of the patch that
introduces the new ndo also use just "ip" not "./ip" and specify that
the default is off.
