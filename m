From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH v2 net 0/5] net:ethernet:aquantia: Misc fixes for atlantic
 driver.
Date: Thu, 23 Mar 2017 01:05:41 +0300
Message-ID: <35924252-6a37-cff8-3c35-a3fffd3f50f9@aquantia.com>
References: <cover.1490217414.git.pavel.belous@aquantia.com>
 <b9effbcb-b201-b197-801c-3ff276b8677d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0083.outbound.protection.outlook.com ([104.47.33.83]:57115
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751250AbdCVWGe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 18:06:34 -0400
In-Reply-To: <b9effbcb-b201-b197-801c-3ff276b8677d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/23/2017 12:44 AM, Florian Fainelli wrote:
> On 03/22/2017 02:19 PM, Pavel Belous wrote:
>> From: Pavel Belous <pavel.belous@aquantia.com>
>>
>> The following patchset containg several fixes for aQuantia AQtion driver
>> for net tree: A couple fixes for IPv6 and other fixes.
>>
>> v1->v2: Fix compilation error (using HW_ATL_A0_TXD_CTL_CMD_IPV6 instead
>>         HW_ATL_B0_TXD_CTL_CMD_IPV6).
>
> Since you are fixing bugs, can you add proper Fixes: <12-digit commit>
> ("Commit subject") tags for each commit?
>
> Also, you may want to fix your subjects to be:
>
> net: ethernet: aquantia: Remove adapter re-opening when MTU changed
>
> Thanks!
>

Thank you, Florian.
I will add 'Fixes' tags in patchset v3.

Regards,
Pavel

>>
>>
>> Pavel Belous (5):
>>   net:ethernet:aquantia: Remove adapter re-opening when mtu changed.
>>   net:ethernet:aquantia: Fix packet type detection (TCP/UDP) for IPv6.
>>   net:ethernet:aquantia: Missing spinlock initialization.
>>   net:ethernet:aquantia: Fix for LSO with IPv6.
>>   net:ethernet:aquantia: Reset is_gso flag when EOP reached.
>>
>>  drivers/net/ethernet/aquantia/atlantic/aq_main.c   |  5 -----
>>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 23 ++++++++++++++++++----
>>  drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  1 +
>>  drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  3 ++-
>>  .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  4 ++++
>>  .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  4 ++++
>>  6 files changed, 30 insertions(+), 10 deletions(-)
>>
>
>
