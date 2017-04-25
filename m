From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: fix calculation of available send sections
Date: Tue, 25 Apr 2017 11:57:19 -0400 (EDT)
Message-ID: <20170425.115719.263296095647066449.davem@davemloft.net>
References: <20170425013338.2653-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950957AbdDYP5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:57:22 -0400
In-Reply-To: <20170425013338.2653-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 24 Apr 2017 18:33:38 -0700

> My change (introduced in 4.11) to use find_first_clear_bit
> incorrectly assumed that the size argument was words, not bits.
> The effect was only a small limited number of the available send
> sections were being actually used. This can cause performance loss
> with some workloads.
> 
> Since map_words is now used only during initialization, it can
> be on stack instead of in per-device data.
> 
> Fixes: b58a185801da ("netvsc: simplify get next send section")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks.
