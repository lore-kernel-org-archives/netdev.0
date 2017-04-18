From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] net: igbvf: Use net_device_stats from
        struct net_device
Date: Tue, 18 Apr 2017 01:36:09 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5EC952@ORSMSX101.amr.corp.intel.com>
References: <20170406064522.13096-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Tobias Klauser <tklauser@distanz.ch>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:51079 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757268AbdDRBgM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 21:36:12 -0400
In-Reply-To: <20170406064522.13096-1-tklauser@distanz.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Tobias Klauser
> Sent: Wednesday, April 5, 2017 11:45 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH] net: igbvf: Use net_device_stats from
> struct net_device
> 
> Instead of using a private copy of struct net_device_stats in
> struct igbvf_adapter, use stats from struct net_device. Also remove the
> now unnecessary .ndo_get_stats function.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/intel/igbvf/igbvf.h  |  1 -
>  drivers/net/ethernet/intel/igbvf/netdev.c | 26 +++++---------------------
>  2 files changed, 5 insertions(+), 22 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
