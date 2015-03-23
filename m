From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 23 Mar 2015 16:45:25 -0400 (EDT)
Message-ID: <20150323.164525.1089841738578904403.davem@davemloft.net>
References: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbbCWUp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:45:27 -0400
In-Reply-To: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Sat, 21 Mar 2015 10:27:28 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
> 
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
> direct bridge ports can be stacked netdevices (like bonds
> and team of switch ports) which may not implement this ndo.
> 
> v2 to v3:
> 	- remove changes to bond and team. Bring back the
> 	transparently following lowerdevs like i initially
> 	had for setlink/getlink
> 	(http://www.spinics.net/lists/netdev/msg313436.html)
> 	dave and scott feldman also seem to prefer it be that
> 	way and move to non-transparent way of doing things
> 	if we see a problem down the lane.
> 
> v3 to v4:
> 	- fix ret initialization
> 
> v4 to v5:
> 	- return err on first failure (scott feldman)
> 
> v5 to v6:
> 	- change variable name (err) and initialize to
> 	-EOPNOTSUPP (scott feldman).
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thank you.
