From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio VF: fix incorrect struct being used
Date: Fri, 06 Jan 2017 15:31:53 -0500 (EST)
Message-ID: <20170106.153153.594647571981551170.davem@davemloft.net>
References: <20170104193155.GA19084@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdAFUbz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:31:55 -0500
In-Reply-To: <20170104193155.GA19084@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 4 Jan 2017 11:31:55 -0800

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> The VF driver is using the wrong struct when sending commands to the NIC
> firmware, sometimes causing adverse effects in the firmware.  The right
> struct is the one that the PF is using, so make the VF use that as well.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
