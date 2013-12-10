From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if
 available
Date: Tue, 10 Dec 2013 14:36:52 -0500 (EST)
Message-ID: <20131210.143652.1279430126319061689.davem@davemloft.net>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
	<CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ffusco@redhat.com, netdev@vger.kernel.org, dev@openvswitch.org,
	dborkman@redhat.com, tgraf@redhat.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3LJTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:36:55 -0500
In-Reply-To: <CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 10 Dec 2013 11:28:08 -0800

> I think this is definitely a good optimization to do given that so
> much of the work that OVS does is hashing. However, isn't there a
> library where there would be a more appropriate place to put this?

I also honestly don't see why we want to special case OVS at all
here.  This faster hashing would be useful for socket demux and
other locations in the kernel.

When I see changes like this my only reaction is "sad face".
