From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [PATCH net] openvswitch: Fix net exit.
Date: Fri, 20 Feb 2015 00:24:46 +0100
Message-ID: <20150219232446.GD29571@pox.localdomain>
References: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dev@openvswitch.org, netdev@vger.kernel.org,
	amuller@redhat.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35133 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbBSXYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 18:24:50 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so12670415wiv.2
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 15:24:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/15 at 11:23am, Pravin B Shelar wrote:
> Open vSwitch allows moving internal vport to different namespace
> while still connected to the bridge. But when namespace deleted
> OVS does not detach these vports, that results in dangling
> pointer to netdevice which causes kernel panic as follows.
> This issue is fixed by detaching all ovs ports from the deleted
> namespace at net-exit.

[...]

> Reported-by: Assaf Muller <amuller@redhat.com>
> Fixes: 46df7b81454("openvswitch: Add support for network namespaces.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Thomas Graf <tgraf@noironetworks.com>
