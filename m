From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 2/2] net/mlx4_en: Add netdev support for
 TCP/IP offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 18:12:02 -0500 (EST)
Message-ID: <20131222.181202.168681767663560253.davem@davemloft.net>
References: <1387725972-10244-1-git-send-email-ogerlitz@mellanox.com>
	<1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3LVXME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:12:04 -0500
In-Reply-To: <1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 22 Dec 2013 17:26:12 +0200

> +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {

Way too many parenthesis, this isn't LISP :-)
