From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Thu, 25 Feb 2016 15:14:51 -0500 (EST)
Message-ID: <20160225.151451.2031977300678070547.davem@davemloft.net>
References: <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
	<56CC7848.2000704@solarflare.com>
	<CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, jesse@kernel.org, aduyck@mirantis.com,
	netdev@vger.kernel.org, alexander.duyck@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665AbcBYUOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:14:53 -0500
In-Reply-To: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 23 Feb 2016 08:47:30 -0800

> Right, GRO should probably not coalesce packets with non-zero IP
> identifiers due to the loss of information.

If they are monotonically increasing, which is the only case worth
caring about, it absolutely should.

Because that can be done without any loss of information.
