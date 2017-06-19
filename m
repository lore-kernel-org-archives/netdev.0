From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: replace info-pointer mode with
 buffer-pointer-only mode
Date: Sun, 18 Jun 2017 23:55:59 -0400 (EDT)
Message-ID: <20170618.235559.1148715988392937305.davem@davemloft.net>
References: <20170618120411.GA1401@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdFSD4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 23:56:02 -0400
In-Reply-To: <20170618120411.GA1401@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Sun, 18 Jun 2017 05:04:11 -0700

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Each Octeon output ring can DMA packets to host memory in two modes:  info-
> pointer mode and buffer-pointer-only mode.  In info-pointer mode, Octeon
> takes two buffer pointers for each packet and places the length of the
> packet along with specified number of bytes from the beginning of the
> packet into one buffer and the rest of the packet in a separate buffer.  In
> buffer-pointer-only mode, Octeon takes single buffer pointer and places the
> length of the packet at the beginning of the buffer followed by the packet
> data.
> 
> This patch switches all Octeon output rings from info-pointer mode to
> buffer-pointer-only mode.  This results in fewer DMA setups and cache line
> snoops.
> 
> Signed-off-by: Prasad Kanneganti <pkanneganti@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
