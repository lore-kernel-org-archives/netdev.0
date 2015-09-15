From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] rtnetlink: catch -EOPNOTSUPP errors from
 ndo_bridge_getlink
Date: Tue, 15 Sep 2015 15:04:26 -0700 (PDT)
Message-ID: <20150915.150426.281510694142997913.davem@davemloft.net>
References: <1442353469-4861-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aderumier@odiso.com, sfeldma@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbIOWE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 18:04:27 -0400
In-Reply-To: <1442353469-4861-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 15 Sep 2015 14:44:29 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
 ...
> ndo_bridge_getlink can return -EOPNOTSUPP when an interfaces
> ndo_bridge_getlink op is set to switchdev_port_bridge_getlink
> and CONFIG_SWITCHDEV is not defined. This today can happen to
> bond, rocker and team devices. This patch adds -EOPNOTSUPP
> checks after calls to ndo_bridge_getlink.
> 
> Fixes: 85fdb956726ff2a ("switchdev: cut over to new switchdev_port_bridge_getlink")
> Reported-by: Alexandre DERUMIER <aderumier@odiso.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v2: fix checkpatch errors

Applied, thanks for fixing this Roopa.
