From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igb: support BCM54616 PHY
Date: Thu, 27 Jul 2017 00:40:01 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C663B22@ORSMSX101.amr.corp.intel.com>
References: <b5d586566a1b523b9be65567b52898e33058a1cf.1500660210.git.>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "John W. Linville" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:60173 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751202AbdG0AkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 20:40:09 -0400
In-Reply-To: <b5d586566a1b523b9be65567b52898e33058a1cf.1500660210.git.>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of John W. Linville
> Sent: Friday, July 21, 2017 11:12 AM
> To: netdev@vger.kernel.org
> Cc: intel-wired-lan@lists.osuosl.org; John W. Linville
> <linville@tuxdriver.com>
> Subject: [Intel-wired-lan] [PATCH] igb: support BCM54616 PHY
> 
> The management port on an Edgecore AS7712-32 switch uses an igb MAC,
> but
> it uses a BCM54616 PHY. Without a patch like this, loading the igb
> module produces dmesg output like this:
> 
> [    3.439125] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    3.439866] igb: probe of 0000:00:14.0 failed with error -2
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c   | 6 ++++++
>  drivers/net/ethernet/intel/igb/e1000_defines.h | 1 +
>  drivers/net/ethernet/intel/igb/e1000_hw.h      | 1 +
>  3 files changed, 8 insertions(+)

I do not have the specific hardware (Edgecore switch) but as far as regression tests go this works fine.
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
