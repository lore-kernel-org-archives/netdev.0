From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [net-next,RESEND] igb: add function to get maximum RSS queues
Date: Wed, 11 Oct 2017 01:45:13 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6BE24C@ORSMSX101.amr.corp.intel.com>
References: <1505828454-2826-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32710 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752099AbdJKBpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 21:45:16 -0400
In-Reply-To: <1505828454-2826-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Zhang Shengju
> Sent: Tuesday, September 19, 2017 6:41 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org
> Subject: [net-next,RESEND] igb: add function to get maximum RSS queues
> 
> This patch adds a new function igb_get_max_rss_queues() to get maximum
> RSS queues, this will reduce duplicate code and facilitate future
> maintenance.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |  1 +
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 32 +---------------------------
>  drivers/net/ethernet/intel/igb/igb_main.c    | 12 +++++++++--
>  3 files changed, 12 insertions(+), 33 deletions(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
