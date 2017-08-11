From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:52:30 -0700
Message-ID: <20170811155230.09df977a@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37928 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753638AbdHKWwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:52:37 -0400
Received: by mail-pg0-f45.google.com with SMTP id l64so20458372pge.5
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 15:52:37 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 19:47:57 +0000
<Bryan.Whitehead@microchip.com> wrote:

> +
> +static int lan743x_ethtool_get_eeprom_len(struct net_device *netdev)
> +{
> +	return 0;
> +}
> +

This stub should go. If you have no eeprom, take the ethtool default.
