From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net 00/18] Update ENA driver to version 1.1.2
Date: Sun, 20 Nov 2016 20:53:46 +0200
Message-ID: <5b832229-8fb0-fc09-6517-b3f855f0eb85@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
 <20161120.102422.733701532971988272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        dwmw@amazon.com, zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36639 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753286AbcKTSxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 13:53:52 -0500
Received: by mail-wm0-f43.google.com with SMTP id g23so113357185wme.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 10:53:52 -0800 (PST)
In-Reply-To: <20161120.102422.733701532971988272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Sorry for not being clear on my first patch set.

Those changes introduce some bug fixes, new features and some cleanups that matching the driver to the upstream standard.

Bug Fixes:
*net/ena: remove RFS support from device feature list
*net/ena: fix queues number calculation
*net/ena: fix ethtool RSS flow configuration
*net/ena: refactor ena_get_stats64 to be atomic context safe
*net/ena: fix potential access to freed memory during device reset
*net/ena: remove redundant logic in napi callback for busy poll mode
*net/ena: fix error handling when probe fails
*net/ena: fix NULL dereference when removing the driver after device
    reset faild
*net/ena: change driver's default timeouts and increase driver version

New Features:
*net/ena: add hardware hints capability to the driver
*net/ena: change condition for host attribute configuration
*net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
*net/ena: remove affinity hint from the driver

Clean ups:
*net/ena: use napi_schedule_irqoff when possible
*net/ena: reduce the severity of ena printouts
*net/ena: change sizeof() argument to be the type pointer
*net/ena: use READ_ONCE to access completion descriptors
*net/ena: refactor skb allocation

I'll add the above description in V2 (I would like to wait a couple of days to collect more feedback about those patches).

Regards,
Netanel

On 11/20/2016 05:24 PM, David Miller wrote:
> From: Netanel Belgazal <netanel@annapurnalabs.com>
> Date: Sun, 20 Nov 2016 10:45:29 +0200
>
>> Update Amazon's Elastic Network Adapter (ENA) driver version from 1.0.2 to 1.1.2
> This is insufficient.
>
> You must explain what this patch series is doing, how it is doing it,
> and why it is doing it that way.
>
> This is the message that people will look at to learn what is
> contained in this series of patches, and they might be looking for
> keywords or explanations as to why a decision was made to add a
> feature, turn a feature off, or make some other important high level
> change to the driver.
