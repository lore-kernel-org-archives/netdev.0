From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 2/2] net/mlx4_en: Add netdev support for
 TCP/IP offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 19:14:00 -0500 (EST)
Message-ID: <20131222.191400.620087948725635345.davem@davemloft.net>
References: <1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
	<20131222.181202.168681767663560253.davem@davemloft.net>
	<1387755159.22671.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	yanb@mellanox.com, ast@plumgrid.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab3LWAOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 19:14:02 -0500
In-Reply-To: <1387755159.22671.27.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 22 Dec 2013 15:32:39 -0800

> On Sun, 2013-12-22 at 18:12 -0500, David Miller wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>> Date: Sun, 22 Dec 2013 17:26:12 +0200
>> 
>> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> > +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> 
>> Way too many parenthesis, this isn't LISP :-)
> 
> Is patchwork stuttering?

I edited it, I'm quoting all of the lines in your patch that add the
"too many parenthsis" problem.
