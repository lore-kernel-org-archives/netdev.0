From: David Miller <davem@davemloft.net>
Subject: Re: ovs inconsistent lock state
Date: Thu, 13 Feb 2014 14:26:54 -0500 (EST)
Message-ID: <20140213.142654.2111989507538583557.davem@davemloft.net>
References: <20140213171307.GC2829@minipsycho.orion>
	<CALnjE+oKrqMVWCrS3kSomxnsSJMFDpFsK8KY+oK1kVTd0Lb8Wg@mail.gmail.com>
	<20140213181257.GD2829@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com,
	dev@openvswitch.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaBMT05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 14:26:57 -0500
In-Reply-To: <20140213181257.GD2829@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 13 Feb 2014 19:12:57 +0100

>>> [ 3014.524118]  [<ffffffff815eb585>] ? __dev_queue_xmit+0x5/0x6a0
  ...
> I fail to see where bh is disabled. ovs_dp_process_received_packet() is
> called with rcu_read_lock...

It happens in __dev_queue_xmit(), which does rcu_read_lock_bh().
