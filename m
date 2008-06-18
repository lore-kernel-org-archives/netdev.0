From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [UPDATED] ixgbe: add LRO support
Date: Wed, 18 Jun 2008 00:04:03 -0400
Message-ID: <48588933.2060605@garzik.org>
References: <20080613183716.9641.33945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, randy.dunlap@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754232AbYFREEW@vger.kernel.org>
In-Reply-To: <20080613183716.9641.33945.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
>=20
> Support for in-kernel LRO with the ability to enable/disable via etht=
ool
> based on comments from Ben Hutchings and Randy Dunlap.
>=20
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel=
=2Ecom>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
>=20
>  drivers/net/Kconfig               |    3 +
>  drivers/net/ixgbe/ixgbe.h         |    9 +++
>  drivers/net/ixgbe/ixgbe_ethtool.c |   11 ++++
>  drivers/net/ixgbe/ixgbe_main.c    |  111 +++++++++++++++++++++++++++=
+++-------
>  4 files changed, 112 insertions(+), 22 deletions(-)


I take that back.

This patch has a bunch of checkpatch problems, and it doesn't even=20
compile, so it obviously was not tested:

drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_receive_skb=E2=
=80=99:
drivers/net/ixgbe/ixgbe_main.c:416: error: implicit declaration of=20
function =E2=80=98vlan_nw_accel_receive_skb=E2=80=99
