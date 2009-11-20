From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: move tc variable to CONFIG_IXGBE_DCB
Date: Fri, 20 Nov 2009 06:24:21 -0800
Message-ID: <9929d2390911200624mf352c28u55a8b2aee8b52fa3@mail.gmail.com>
References: <1258725747.3562.5.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:37847 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbZKTOYP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 09:24:15 -0500
In-Reply-To: <1258725747.3562.5.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 06:02, Jaswinder Singh Rajput
<jaswinder@kernel.org> wrote:
>
> tc is required by CONFIG_IXGBE_DCB.
> This also fixes compilation warning:
>
> =C2=A0drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_tx_i=
s_paused=E2=80=99:
> =C2=A0drivers/net/ixgbe/ixgbe_main.c:245: warning: unused variable =E2=
=80=98tc=E2=80=99
>
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index ebcec30..61a02ce 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -242,11 +242,11 @@ static void ixgbe_unmap_and_free_tx_resource(st=
ruct ixgbe_adapter *adapter,
> =C2=A0static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *ada=
pter,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct =
ixgbe_ring *tx_ring)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int tc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 txoff =3D IXGBE_TFCS_TXOFF;
>
> =C2=A0#ifdef CONFIG_IXGBE_DCB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (adapter->flags & IXGBE_FLAG_DCB_ENABLE=
D) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int tc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int reg_idx =3D=
 tx_ring->reg_idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int dcb_i =3D =
adapter->ring_feature[RING_F_DCB].indices;
>
> --
> 1.6.5.3
>
>
> --

I just submitted a patch to fix this.  So NAK.

--=20
Cheers,
Jeff
