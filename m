From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Introduce support in
 SKIP SW flag
Date: Tue, 07 Jun 2016 15:50:06 -0700 (PDT)
Message-ID: <20160607.155006.1171124874702317139.davem@davemloft.net>
References: <20160605141118.10986-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, ogerlitz@mellanox.com,
	hadarh@mellanox.com, amirva@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161196AbcFGWuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:50:09 -0400
In-Reply-To: <20160605141118.10986-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Sun,  5 Jun 2016 17:11:18 +0300

> From: Amir Vadai <amirva@mellanox.com>
> 
> In order to make a filter processed only by hardware, skip_sw flag
> should be supplied. This is an addition to the already existing skip_hw
> flag (filter will be processed by software only). If no flag is
> specified, filter will be processed by both software and hardware.
> 
> If only hardware offloaded filters exist, fl_classify() will return
> without doing anything.
> 
> A following userspace patch will be sent once kernel patch is accepted.
> 
> Example:
> 
> tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
> 	flower \
> 		ip_proto 6 \
> 		indev enp0s9 \
> 		skip_sw \
> 	action skbedit mark 0x1234
> 
> Signed-off-by: Amir Vadai <amirva@mellanox.com>

Applied.
