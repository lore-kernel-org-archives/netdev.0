From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/13] bonding: remove vlan special handling
Date: Thu, 29 Aug 2013 16:20:58 -0400 (EDT)
Message-ID: <20130829.162058.321510029835854765.davem@davemloft.net>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, fubar@us.ibm.com,
	andy@greyhouse.net, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab3H2UVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:21:02 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed, 28 Aug 2013 23:25:03 +0200

> The aim of this patchset is to remove bondings' own vlan handling as much
> as possible and replace it with the netdev upper device functionality.
> 
> The upper device functionality is extended to include also lower devices
> and to have, for each device, a full view of every lower and upper device,
> but not only the first-level ones. This might permit in the future to
> avoid, for any grouping/teaming/upper/lower devices, to maintain its own
> lists of slaves/vlans/etc.
> 
> This is achieved by adding a helper function to upper dev list handling -
> netdev_upper_get_next_dev(dev, iter), which returns the next device after
> the list_head **iter, and sets *iter to the next list_head *. This patchset
> also adds netdev_for_each_upper_dev(dev, upper, iter), which iterates
> through the whole dev->upper_dev_list, setting upper to the net_device.
> The only special treatment of vlans remains in rlb code.
> 
> This patchset solves several issues with bonding, simplifies it overall,
> RCUify further and exports upper list functions for any other users which
> might also want to get rid of its own vlan_lists or slaves.
> 
> I'm testing it continuously currently, no issues found, will update on
> anything.

I like these changes a lot, nice work.

Series applied, thanks.
