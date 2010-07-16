From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Drivers: net: 8139cp: Fixed 28 style errors, and 119
  warnings.
Date: Thu, 15 Jul 2010 20:57:19 -0400
Message-ID: <4C3FAE6F.3020406@garzik.org>
References: <AANLkTikspw9LxFFsXJgWn30k2qCVu5zkOAq2FhWTpQvW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joseph Kogut <joseph.kogut@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41405 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935102Ab0GPA5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 20:57:24 -0400
In-Reply-To: <AANLkTikspw9LxFFsXJgWn30k2qCVu5zkOAq2FhWTpQvW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
> -#define RX_FIFO_THRESH         5       /* Rx buffer level before first PCI xfer.  */
> +/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6 == 1024, 7 == end of packet. */
> +#define RX_FIFO_THRESH         5       /* Rx buffer level before first PCI xfer. */

useless noise

> -       unsigned                wol_enabled : 1; /* Is Wake-on-LAN enabled? */
> +       unsigned                wol_enabled:1; /* Is Wake-on-LAN enabled? */

not an improvement

> -               if (wol->wolopts & WAKE_PHY)    options |= LinkUp;
> -               if (wol->wolopts & WAKE_MAGIC)  options |= MagicPacket;
> +               if (wol->wolopts & WAKE_PHY)
> +                       options |= LinkUp;
> +               if (wol->wolopts & WAKE_MAGIC)
> +                       options |= MagicPacket;

ditto

> -               if (wol->wolopts & WAKE_UCAST)  options |= UWF;
> -               if (wol->wolopts & WAKE_BCAST)  options |= BWF;
> -               if (wol->wolopts & WAKE_MCAST)  options |= MWF;
> +               if (wol->wolopts & WAKE_UCAST)
> +                       options |= UWF;
> +               if (wol->wolopts & WAKE_BCAST)
> +                       options |= BWF;
> +               if (wol->wolopts & WAKE_MCAST)
> +                       options |= MWF;

ditto
>
> -       if (options & UWF)           wol->wolopts |= WAKE_UCAST;
> -       if (options & BWF)           wol->wolopts |= WAKE_BCAST;
> -       if (options & MWF)           wol->wolopts |= WAKE_MCAST;
> +       options        = cpr8(Config5);
> +       if (options & UWF)
> +               wol->wolopts |= WAKE_UCAST;
> +       if (options & BWF)
> +               wol->wolopts |= WAKE_BCAST;
> +       if (options & MWF)
> +               wol->wolopts |= WAKE_MCAST;

ditto

