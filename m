From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/9] ftgmac100: Rework batch 5 - Features
Date: Tue, 18 Apr 2017 14:11:26 -0400 (EDT)
Message-ID: <20170418.141126.1009103356108982429.davem@davemloft.net>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdDRSL2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 14:11:28 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 18 Apr 2017 08:36:57 +1000

> This is the third spin of the fifth and last batch of
> updates to the ftgmac100 driver.
> 
> This contains a few additional "features" such as:
> 
>  - Support for ethtool n-way reset
>  - Multicast filtering & promisc support
>  - Vlan offload
>  - netpoll
> 
> And a couple of misc bits. This also adds the device-tree binding
> documentation.
> 
> v2. - Addresses review comments and adds a new patch fixing a
>       theorical ordering issue in my new NAPI poll implementation
>     - Add a bug fix (Patch 8/9) for a potential ordering issue
>       in the new NAPI poll code.
> 
> v3. - Rebase on net-next (fix conflict with an unrelated #include
>       change series)
>     - Update DT bindings better describing accepted phy-mode values

Series applied, thanks Ben.
