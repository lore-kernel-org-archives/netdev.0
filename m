From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] openvswitch: restore OVS_FLOW_CMD_NEW
 notifications
Date: Fri, 19 Sep 2014 17:29:05 -0400 (EDT)
Message-ID: <20140919.172905.1914686320808799824.davem@davemloft.net>
References: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
	<1411029064-15376-1-git-send-email-nicolas.dichtel@6wind.com>
	<1411029064-15376-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	samuel.gauthier@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728AbaISV3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:29:07 -0400
In-Reply-To: <1411029064-15376-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 18 Sep 2014 10:31:04 +0200

> From: Samuel Gauthier <samuel.gauthier@6wind.com>
> 
> Since commit fb5d1e9e127a ("openvswitch: Build flow cmd netlink reply only if needed."),
> the new flows are not notified to the listeners of OVS_FLOW_MCGROUP.
> 
> This commit fixes the problem by using the genl function, ie
> genl_has_listerners() instead of netlink_has_listeners().
> 
> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Also applied, thanks.
