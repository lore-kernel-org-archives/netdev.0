From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] net: intel: ixgb: use new api
        ethtool_{get|set}_link_ksettings
Date: Tue, 14 Mar 2017 02:08:33 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5B402C@ORSMSX101.amr.corp.intel.com>
References: <1486336271-25336-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:14397 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752044AbdCNCIg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 22:08:36 -0400
In-Reply-To: <1486336271-25336-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Philippe Reynes
> Sent: Sunday, February 5, 2017 3:11 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; Philippe Reynes <tremyfr@gmail.com>
> Subject: [Intel-wired-lan] [PATCH] net: intel: ixgb: use new api
> ethtool_{get|set}_link_ksettings
> 
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c |   39 ++++++++++++++---------
> -
>  1 files changed, 23 insertions(+), 16 deletions(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Well, compile / static tested by:  I probably have an ixgb adapter somewhere as well as a PCI-X slot that might work for it, but am not sure I can find them or that they still function.  If I stumble upon one I'll fire it up and run it through some paces, but the variant of this patch for other drivers seem good and I don't want to hold this patch up any longer.
