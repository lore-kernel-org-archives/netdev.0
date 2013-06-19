From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next 3/8] i40e: driver ethtool core
Date: Wed, 19 Jun 2013 11:38:25 -0700
Message-ID: <20130619113825.45cc7f32@samsung-9>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:48084 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756845Ab3FSSia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:38:30 -0400
Received: by mail-pb0-f44.google.com with SMTP id uo1so5370667pbc.3
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:38:29 -0700 (PDT)
In-Reply-To: <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Jun 2013 20:55:17 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> +static const struct i40e_stats i40e_gstrings_net_stats[] = {
> +	I40E_NETDEV_STAT(rx_packets),
> +	I40E_NETDEV_STAT(tx_packets),
> +	I40E_NETDEV_STAT(rx_bytes),
> +	I40E_NETDEV_STAT(tx_bytes),
> +	I40E_NETDEV_STAT(rx_errors),
> +	I40E_NETDEV_STAT(tx_errors),
> +	I40E_NETDEV_STAT(rx_dropped),
> +	I40E_NETDEV_STAT(tx_dropped),
> +	I40E_NETDEV_STAT(multicast),
> +	I40E_NETDEV_STAT(collisions),
> +	I40E_NETDEV_STAT(rx_length_errors),
> +	I40E_NETDEV_STAT(rx_over_errors),
> +	I40E_NETDEV_STAT(rx_crc_errors),
> +	I40E_NETDEV_STAT(rx_frame_errors),
> +	I40E_NETDEV_STAT(rx_fifo_errors),
> +	I40E_NETDEV_STAT(tx_aborted_errors),
> +	I40E_NETDEV_STAT(tx_carrier_errors),
> +	I40E_NETDEV_STAT(tx_fifo_errors),
> +	I40E_NETDEV_STAT(tx_heartbeat_errors),
> +	I40E_NETDEV_STAT(tx_window_errors),
> +	I40E_NETDEV_STAT(rx_compressed),
> +	I40E_NETDEV_STAT(tx_compressed),
> +}

Why duplicate network device stats in ethtool stats?
