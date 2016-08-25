From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH -next] igb: fix non static symbol warning
Date: Thu, 25 Aug 2016 19:23:02 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F7746A@ORSMSX101.amr.corp.intel.com>
References: <1471964889-511-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53444 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755253AbcHYTXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 15:23:04 -0400
In-Reply-To: <1471964889-511-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Wei Yongjun
> Sent: Tuesday, August 23, 2016 8:08 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Wei Yongjun <weiyongjun1@huawei.com>; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org
> Subject: [PATCH -next] igb: fix non static symbol warning
> 
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/ethernet/intel/igb/igb_ethtool.c:2707:5: warning:
>  symbol 'igb_rxnfc_write_vlan_prio_filter' was not declared. Should it be
> static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
