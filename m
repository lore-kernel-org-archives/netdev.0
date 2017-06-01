From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] qed: Status block changes
Date: Thu, 01 Jun 2017 12:17:41 -0400 (EDT)
Message-ID: <20170601.121741.830895730989049957.davem@davemloft.net>
References: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752184AbdFAQRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:17:47 -0400
In-Reply-To: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Thu, 1 Jun 2017 15:29:00 +0300

> The device maintains a CAM mapping of the internal status blocks
> and the various PF/VF MSI-x vector mappings.
> During initialization, the driver reads the HW memory and constructs
> a shadow SW implementation which it would later use for manipulation
> of interrupts. E.g., when enabling VFs and setting their MSI-x tables.
> 
> The driver currently has some very strict assumptions on the order the
> entries are placed in the CAM. Specifically, it assumes that all entries
> belonging to a PF would be consecutive and in-order in the CAM, and that
> the VF entries would then follow. But there's no actual HW constraint
> enforcing this assumption [although management firmware does set it
> accordingly to same assumption initially].
> 
> Since the CAM is re-configurable, there are now SW flows employeed
> by other OSes that might cause the assumption to be invalid.
> Such flows allow the PF to forfeit some of it's available interrupts
> in favor of its VFs or vice versa.
> While those are not employeed today by qed, we want to relax the
> assumptions as much as we can -
> both to allow functionality after PDA as well as allowing future
> compatibility where the driver would be loaded after a newer one has
> 'dirtied' the CAM configuration.
> 
> In addition to patches meant for the above relaxation, the series
> also contains various cleanups & refactoring for interrupt logic
> [most of which is !semantic].

Series applied, thank you.
