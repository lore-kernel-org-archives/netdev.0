From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] {vxlan,inet6} Mark vxlan_dev flags with
 VXLAN_F_IPV6 properly
Date: Fri, 03 Jan 2014 20:36:39 -0500 (EST)
Message-ID: <20140103.203639.681823919697735127.davem@davemloft.net>
References: <1388715538-27385-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, rcwhelan@gmail.com,
	netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442AbaADBgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:36:42 -0500
In-Reply-To: <1388715538-27385-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 3 Jan 2014 10:18:58 +0800

> Even if user doesn't supply the physical netdev to attach vxlan dev
> to, and at the same time user want to vxlan sit top of IPv6, mark
> vxlan_dev flags with VXLAN_F_IPV6 to create IPv6 based socket.
> Otherwise kernel crashes safely every time spitting below messages,
> 
> Steps to reproduce:
> ip link add vxlan0 type vxlan id 42 group ff0e::110
> ip link set vxlan0 up
 ...
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Reported-by: Ryan Whelan <rcwhelan@gmail.com>

Applied, thank you.
