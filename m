From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH] enic: Store permanent MAC address during probe()
Date: Mon, 20 Mar 2017 17:33:17 -0700
Message-ID: <alpine.LNX.2.20.1703201701590.17033@cisco>
References: <20170320224120.24484-1-pjw@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: <netdev@vger.kernel.org>, Christian Benvenuti <benve@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Neel Patel <neepatel@cisco.com>
To: PJ Waskiewicz <pjwaskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-7.cisco.com ([173.37.142.94]:33118 "EHLO
        alln-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754218AbdCUBFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 21:05:24 -0400
In-Reply-To: <20170320224120.24484-1-pjw@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Mar 2017, PJ Waskiewicz wrote:

> From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
>
> The permanent MAC address is useful to store for things like ethtool,
> and when bonding with modes such as active/passive or LACP.

Hi Peter,

Is this patch fixing an issue with bonding drive on enic?

> This follows the model of other Ethernet drivers, such as ixgbe.
>

While other drivers set netdev->perm_addr, doesn't this actually come free in
register_netdevice().
