From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net-next] ixgb: Omit private ndo_get_stats function
Date: Fri, 24 Mar 2017 22:08:48 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5DDEA1@ORSMSX101.amr.corp.intel.com>
References: <20170215110820.30052-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Joe Perches" <joe@perches.com>
To: Tobias Klauser <tklauser@distanz.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:26154 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752767AbdCXWIv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 18:08:51 -0400
In-Reply-To: <20170215110820.30052-1-tklauser@distanz.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Tobias Klauser
> Sent: Wednesday, February 15, 2017 3:08 AM
> To: netdev@vger.kernel.org
> Cc: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-
> lan@lists.osuosl.org; Joe Perches <joe@perches.com>
> Subject: [PATCH net-next] ixgb: Omit private ndo_get_stats function
> 
> ixgb_get_stats() just returns dev->stats so we can leave it
> out altogether and let dev_get_stats() do the job.
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c | 16 ----------------
>  1 file changed, 16 deletions(-)

Well, well.  I managed to locate one of my ixgb based adapters as well as a system with a working PCI-X bus to host it.

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
