From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH v2 net-next 2/3] net: dsa: lan9303: define LAN9303_NUM_PORTS 3
Date: Tue, 1 Aug 2017 13:49:51 +0200
Message-ID: <201708011349.52529.jbe@pengutronix.de>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no> <20170801111439.1143-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57359 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751595AbdHALt5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 07:49:57 -0400
In-Reply-To: <20170801111439.1143-3-privat@egil-hjelmeland.no>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

On Tuesday 01 August 2017 13:14:38 Egil Hjelmeland wrote:
> Will be used instead of '3' in upcomming patches.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> ---
>  drivers/net/dsa/lan9303-core.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/dsa/lan9303-core.c
> b/drivers/net/dsa/lan9303-core.c index 4c514d3b9f68..2a3c6bf473dd 100644
> --- a/drivers/net/dsa/lan9303-core.c
> +++ b/drivers/net/dsa/lan9303-core.c
> @@ -20,6 +20,8 @@
>
>  #include "lan9303.h"
>
> +#define LAN9303_NUM_PORTS 3
> +
>  /* 13.2 System Control and Status Registers
>   * Multiply register number by 4 to get address offset.
>   */

Maybe we should put this macro into a shared location because 
in "net/dsa/tag_lan9303.c" there is already a "#define LAN9303_MAX_PORTS 
3".

jb

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
