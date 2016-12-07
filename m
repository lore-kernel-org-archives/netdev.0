From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Wed, 7 Dec 2016 03:41:43 +0100
Message-ID: <20161207024143.GA655@lunn.ch>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47162 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbcLGClt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 21:41:49 -0500
Content-Disposition: inline
In-Reply-To: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
> Hi Dave,
> 
> This series adds the support for setting device registers from user
> space ethtool.

Is this not the start of allowing binary only drivers in user space?

Do we want this?

> mlx5 driver have registers allowed access list and will check the user 
> Request validity before forwarding it to HW registers. Mlx5 will allow only mlx5 specific
> configurations to be set (e.g. Device Diag Counters for HW performance debugging and analysis)
> which has no standard API to access it.

Would it not be better to define an flexible API to do this? We have
lots of HW performance counters for CPUs. Why is it not possible to do
this for a network device?

      Andrew
