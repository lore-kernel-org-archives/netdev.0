From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] e1000e: fix timing for 82579 Gigabit Ethernet controller
Date: Fri, 24 Mar 2017 00:43:12 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5DC96A@ORSMSX101.amr.corp.intel.com>
References: <1487270527-4549-1-git-send-email-berndfaust@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Bernd Faust <berndfaust@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Lubetkin, YanirX" <yanirx.lubetkin@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43749 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756896AbdCXAtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 20:49:03 -0400
In-Reply-To: <1487270527-4549-1-git-send-email-berndfaust@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Bernd Faust
> Sent: Thursday, February 16, 2017 10:42 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Lubetkin, YanirX
> <yanirx.lubetkin@intel.com>; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Bernd Faust <berndfaust@gmail.com>
> Subject: [PATCH] e1000e: fix timing for 82579 Gigabit Ethernet controller
>=20
> After an upgrade to Linux kernel v4.x the hardware timestamps of the
> 82579 Gigabit Ethernet Controller are different than expected.
> The values that are being read are almost four times as big as before
> the kernel upgrade.
>=20
> The difference is that after the upgrade the driver sets the clock
> frequency to 25MHz, where before the upgrade it was set to 96MHz. Intel
> confirmed that the correct frequency for this network adapter is 96MHz.
>=20
> Signed-off-by: Bernd Faust <berndfaust@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++++
>  1 file changed, 6 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
