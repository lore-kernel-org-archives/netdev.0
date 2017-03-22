From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 0/5] net:ethernet:aquantia: Misc fixes for atlantic
 driver.
Date: Wed, 22 Mar 2017 14:44:33 -0700
Message-ID: <b9effbcb-b201-b197-801c-3ff276b8677d@gmail.com>
References: <cover.1490217414.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34246 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdCVVoj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:44:39 -0400
Received: by mail-wr0-f193.google.com with SMTP id y90so4869866wrb.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:44:38 -0700 (PDT)
In-Reply-To: <cover.1490217414.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2017 02:19 PM, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> The following patchset containg several fixes for aQuantia AQtion driver
> for net tree: A couple fixes for IPv6 and other fixes.
> 
> v1->v2: Fix compilation error (using HW_ATL_A0_TXD_CTL_CMD_IPV6 instead
>         HW_ATL_B0_TXD_CTL_CMD_IPV6).

Since you are fixing bugs, can you add proper Fixes: <12-digit commit>
("Commit subject") tags for each commit?

Also, you may want to fix your subjects to be:

net: ethernet: aquantia: Remove adapter re-opening when MTU changed

Thanks!

> 
> 
> Pavel Belous (5):
>   net:ethernet:aquantia: Remove adapter re-opening when mtu changed.
>   net:ethernet:aquantia: Fix packet type detection (TCP/UDP) for IPv6.
>   net:ethernet:aquantia: Missing spinlock initialization.
>   net:ethernet:aquantia: Fix for LSO with IPv6.
>   net:ethernet:aquantia: Reset is_gso flag when EOP reached.
> 
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c   |  5 -----
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 23 ++++++++++++++++++----
>  drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  1 +
>  drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  3 ++-
>  .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  4 ++++
>  .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  4 ++++
>  6 files changed, 30 insertions(+), 10 deletions(-)
> 


-- 
Florian
