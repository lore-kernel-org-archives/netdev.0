From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Thu, 3 Aug 2017 16:16:04 -0700
Message-ID: <20170803161604.4d3d5ea1@xeon-e3>
References: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: "Jianming.qiao" <jqiaoulk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35110 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:16:07 -0400
Received: by mail-pf0-f175.google.com with SMTP id t86so640896pfe.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:16:07 -0700 (PDT)
In-Reply-To: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Aug 2017 00:07:45 +0100
"Jianming.qiao" <jqiaoulk@gmail.com> wrote:

>  static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
>  	/* general stats */
> -	STAT_NETDEV(rx_packets),
> -	STAT_NETDEV(tx_packets),
> -	STAT_NETDEV(rx_bytes),
> -	STAT_NETDEV(tx_bytes),
> +	STAT_NETDEV64(rx_packets),
> +	STAT_NETDEV64(tx_packets),
> +	STAT_NETDEV64(rx_bytes),
> +	STAT_NETDEV64(tx_bytes),
>  	STAT_NETDEV(rx_errors),

Please don't duplicate regular statistics (ie netdev) into ethtool.
It is a needless duplication.
