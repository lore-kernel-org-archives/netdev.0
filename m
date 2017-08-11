From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:49:55 -0700
Message-ID: <20170811154955.47c9cf74@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:38612 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdHKWuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:50:02 -0400
Received: by mail-pg0-f41.google.com with SMTP id l64so20441424pge.5
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 15:50:02 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

;
> +
> +static void lan743x_rx_isr(void *context, u32 int_sts);
> +
> +static int lan743x_rx_ring_init(struct lan743x_rx *rx);
> +static void lan743x_rx_ring_cleanup(struct lan743x_rx *rx);
> +static int lan743x_rx_init(struct lan743x_rx *rx,
> +			   struct lan743x_adapter *adapter, int channel_number);
> +static void lan743x_rx_cleanup(struct lan743x_rx *rx);
> +static int lan743x_rx_open(struct lan743x_rx *rx);
> +static void lan743x_rx_close(struct lan743x_rx *rx);
> +

Please don't create a header file full of static declarations.
Header files are for shared data between compilation units.

Also, Linux style is to order functions to minimize the number
of required forward declarations.
