From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 11 Feb 2011 07:55:35 -0800
Message-ID: <AANLkTimo1itFgO2K76VvKso=SrVjF9FEpO8twmFrq1pZ@mail.gmail.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52183 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889Ab1BKPzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 10:55:35 -0500
Received: by iwn9 with SMTP id 9so2538418iwn.19
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 07:55:35 -0800 (PST)
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 8, 2011 at 04:29, Jeff Kirsher <jeffrey.t.kirsher@intel.com=
> wrote:
> The following series contains e1000e cleanup patches, the addition of=
 igb
> PF support for i350 devices and several ixgbe cleanup patches.
>
> The following are changes since commit 2360d2e8f01043632d6b651672bec6=
6c49892f94:
> =C2=A0enic: Update MAINTAINERS
>
> and are available in the git repository at:
> =C2=A0master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2=
=2E6 master
>
> Atita Shirwaikar (1):
> =C2=A0ixgbe: Adding 100MB FULL support in ethtool
>
> Bruce Allan (4):
> =C2=A0e1000e: replace unbounded sprintf with snprintf
> =C2=A0e1000e: use correct pointer when memcpy'ing a 2-dimensional arr=
ay
> =C2=A0e1000e: do not wakeup Tx queue until ready
> =C2=A0e1000e: return appropriate errors for 'ethtool -r'
>
> Carolyn Wyborny (1):
> =C2=A0igb: Enable PF side of SR-IOV support for i350 devices
>
> Don Skidmore (3):
> =C2=A0ixgbe: fix namespace issue with ixgbe_dcb_txq_to_tc
> =C2=A0ixgbe: cleanup namespace complaint by removing little used func=
tion
> =C2=A0ixgbe: cleanup ixgbe_init_mbx_params_pf namespace issue
>
> John Fastabend (7):
> =C2=A0ixgbe: DCB, only reprogram HW if the FCoE priority is changed
> =C2=A0ixgbe: DCB, remove round robin mode on 82598 devices
> =C2=A0ixgbe: DCB, abstract out dcb_config from DCB hardware configura=
tion
> =C2=A0ixgbe: DCB, implement 802.1Qaz routines
> =C2=A0ixgbe: DCB, do not reset on CEE pg changes
> =C2=A0ixgbe: DCB, remove RESET bit it is no longer needed
> =C2=A0ixgbe: dcb, use hardware independent routines
>
> =C2=A0drivers/net/e1000e/ethtool.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 13 ++-
> =C2=A0drivers/net/e1000e/netdev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 13 +-
> =C2=A0drivers/net/igb/e1000_82575.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 10 =
++-
> =C2=A0drivers/net/igb/e1000_mbx.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 38 +++----
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 =C2=A09 +-
> =C2=A0drivers/net/ixgbe/ixgbe.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A05 +-
> =C2=A0drivers/net/ixgbe/ixgbe_common.h =C2=A0 =C2=A0| =C2=A0 =C2=A04 =
+-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0176 =
+++++++++++++++++++++++++++++-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 10 =
++-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb_82598.c | =C2=A0 94 ++++++++-------=
-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb_82598.h | =C2=A0 23 ++++-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb_82599.c | =C2=A0115 +++++++++++----=
----
> =C2=A0drivers/net/ixgbe/ixgbe_dcb_82599.h | =C2=A0 24 ++++-
> =C2=A0drivers/net/ixgbe/ixgbe_dcb_nl.c =C2=A0 =C2=A0| =C2=A0211 +++++=
+++++++++++++++++++++--------
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c =C2=A0 | =C2=A0 34 ++++++-
> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 18 =
+--
> =C2=A0drivers/net/ixgbe/ixgbe_mbx.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +
> =C2=A0drivers/net/ixgbe/ixgbe_mbx.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +
> =C2=A0include/linux/dcbnl.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A05 +
> =C2=A019 files changed, 601 insertions(+), 205 deletions(-)
>
> --

I will drop patch 3 (e1000e: do not wakeup Tx queue until ready) while
Bruce takes a second look at the patch.  I will be re-posting a pull
request once I have updated my net-next tree without that patch.

--=20
Cheers,
Jeff
