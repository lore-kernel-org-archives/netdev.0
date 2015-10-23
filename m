From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: Fix egress tunnel info.
Date: Thu, 22 Oct 2015 19:17:02 -0700 (PDT)
Message-ID: <20151022.191702.1291802279822540087.davem@davemloft.net>
References: <1445549370-8973-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbbJWCAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 22:00:33 -0400
In-Reply-To: <1445549370-8973-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 22 Oct 2015 14:29:30 -0700

> While transitioning to netdev based vport we broke OVS
> feature which allows user to retrieve tunnel packet egress
> information for lwtunnel devices.  Following patch fixes it
> by introducing ndo operation to get the tunnel egress info.
> Same ndo operation can be used for lwtunnel devices and compat
> ovs-tnl-vport devices. So after adding such device operation
> we can remove similar operation from ovs-vport.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device").
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v1-v2:
> - changed ndo operation name to ndo_fill_metadata_dst()
> - Fix geneve stats update

Please kill the unused local variable found by the kbuild test
robot.

Thanks.
