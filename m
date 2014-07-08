From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Don't configure the HW vxlan parser
 when vxlan offloading isn't set
Date: Mon, 07 Jul 2014 21:40:08 -0700 (PDT)
Message-ID: <20140707.214008.1100817705691828133.davem@davemloft.net>
References: <1404311783-7963-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbaGHEkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:40:09 -0400
In-Reply-To: <1404311783-7963-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  2 Jul 2014 17:36:23 +0300

> The add_vxlan_port ndo driver code was wrongly testing whether HW vxlan offloads
> are supported by the device instead of checking if they are currently enabled.
> 
> This causes the driver to configure the HW parser to conduct matching for vxlan
> packets but since no steering rules were set, vxlan packets are dropped on RX.
> 
> Fix that by doing the right test, as done in the del_vxlan_port ndo handler.
> 
> Fixes: 1b136de ('net/mlx4: Implement vxlan ndo calls')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> 
> Hi Dave,
> 
> This fixes a bug from 3.15-rc1, can you please push to 3.15.y too?

Applied and queued up for -stable, thanks.
