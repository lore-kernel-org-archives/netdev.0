From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: RX ntuple feature must check num_rx_queues
Date: Tue, 10 May 2011 11:52:02 -0700
Message-ID: <BANLkTinq4u321Cf=JtkKOW=6WMP=y78+SQ@mail.gmail.com>
References: <OFA595D9DB.234DFCEB-ON8525788C.004ED485-8525788C.004ED485@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian.Poehn@belden.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61069 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab1EJSwE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:52:04 -0400
Received: by fxm17 with SMTP id 17so4514477fxm.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 11:52:03 -0700 (PDT)
In-Reply-To: <OFA595D9DB.234DFCEB-ON8525788C.004ED485-8525788C.004ED485@BeldenCDT.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2011 at 07:21,  <Sebastian.Poehn@belden.com> wrote:
> The driver must check how much RX queues there are, not TX queues.
>
> --- ixgbe_ethtool.c.orig=C2=A0=C2=A0=C2=A0 2011-05-10 16:18:00.313745=
560 +0200
> +++ ixgbe_ethtool.c=C2=A0=C2=A0=C2=A0 2011-05-10 16:18:23.285747635 +=
0200
> @@ -2349,9 +2349,9 @@ static int ixgbe_set_rx_ntuple(struct ne
>
> =C2=A0=C2=A0=C2=A0=C2=A0 /*
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* Don't allow programming if the actio=
n is a queue greater than
> -=C2=A0=C2=A0=C2=A0 =C2=A0* the number of online Tx queues.
> +=C2=A0=C2=A0=C2=A0 =C2=A0* the number of online Rx queues.
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0*/
> -=C2=A0=C2=A0=C2=A0 if ((fs->action >=3D adapter->num_tx_queues) ||
> +=C2=A0=C2=A0=C2=A0 if ((fs->action >=3D adapter->num_rx_queues) ||
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 (fs->action < ETHTOOL_RXN=
TUPLE_ACTION_DROP))
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return -EINVAL;
>
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

Thanks Sebastian, I have added the patch to my queue of patches.

--=20
Cheers,
Jeff
