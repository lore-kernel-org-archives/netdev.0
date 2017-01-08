From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: simplify octeon_flush_iq()
Date: Sun, 08 Jan 2017 17:13:25 -0500 (EST)
Message-ID: <20170108.171325.376435036571451564.davem@davemloft.net>
References: <20170107011612.GA16333@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752812AbdAHWNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:13:37 -0500
In-Reply-To: <20170107011612.GA16333@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 6 Jan 2017 17:16:12 -0800

> From: Derek Chickles <derek.chickles@cavium.com>
> 
> Because every call to octeon_flush_iq() has a hardcoded 1 for the
> pending_thresh argument, simplify that function by removing that argument.
> This avoids one atomic read as well.
> 
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
