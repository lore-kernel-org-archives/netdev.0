From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if
 available
Date: Tue, 10 Dec 2013 17:38:32 -0500 (EST)
Message-ID: <20131210.173832.401837941212576450.davem@davemloft.net>
References: <CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
	<20131210.143652.1279430126319061689.davem@davemloft.net>
	<52A77DF4.5070302@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, ffusco@redhat.com, netdev@vger.kernel.org,
	dev@openvswitch.org, dborkman@redhat.com
To: tgraf@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3LJWif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:38:35 -0500
In-Reply-To: <52A77DF4.5070302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@redhat.com>
Date: Tue, 10 Dec 2013 21:47:48 +0100

> We were not sure whether the runtime check, function pointer and
> hardware dependencies are something other subsystems that are less
> x86_64 centric would want to live with.

The things you are listing as implicit overhead can be eliminated
almost entirely using static branches.
