From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 06/12] [MAC802154] mac802154: MIB support
Date: Wed, 30 Nov 2011 20:00:16 +0400
Message-ID: <CALT56yNyfxs5XEeUgEd77wBbKtaGSKjB9a8U6nK1=3N1Uv+GBA@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
	<1322663105-3952-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50317 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab1K3QAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:00:17 -0500
Received: by qyk4 with SMTP id 4so429736qyk.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:00:17 -0800 (PST)
In-Reply-To: <1322663105-3952-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 30, 2011 at 6:25 PM, Alexander Smirnov
<alex.bluesman.smirnov@gmail.com> wrote:
> Support for IEEE 802.15.4 management information base,
> routine like setting of HW address, PAN id, channel etc...
>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
> =A0include/linux/if.h =A0 =A0 =A0 =A0| =A0 =A03 +
> =A0net/mac802154/Makefile =A0 =A0| =A0 =A02 +-
> =A0net/mac802154/mac802154.h | =A0 22 ++++
> =A0net/mac802154/mib.c =A0 =A0 =A0 | =A0247 +++++++++++++++++++++++++=
++++++++++++++++++++
> =A0net/mac802154/mib.h =A0 =A0 =A0 | =A0 35 +++++++
> =A05 files changed, 308 insertions(+), 1 deletions(-)
> =A0create mode 100644 net/mac802154/mib.c
> =A0create mode 100644 net/mac802154/mib.h
>
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 06b6ef6..deaf14c 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -76,6 +76,9 @@
> =A0#define IFF_BRIDGE_PORT =A0 =A0 =A0 =A00x4000 =A0 =A0 =A0 =A0 =A0/=
* device used as bridge port */
> =A0#define IFF_OVS_DATAPATH =A0 =A0 =A0 0x8000 =A0/* device used as O=
pen vSwitch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * datapath port */
> +
> +#define IFF_IEEE802154_COORD =A0 0x400 =A0 /* IEEE802.15.4 PAN coord=
inator */
> +

I remember this define, but I don't remember why we did it this way.
Is it suitable
to use this namespace for device-specific flags?

> =A0#define IFF_TX_SKB_SHARING =A0 =A0 0x10000 /* The interface suppor=
ts sharing
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * skbs on transmit */
> =A0#define IFF_UNICAST_FLT =A0 =A0 =A0 =A00x20000 =A0 =A0 =A0 =A0 /* =
Supports unicast filtering =A0 */

--=20
With best wishes
Dmitry
