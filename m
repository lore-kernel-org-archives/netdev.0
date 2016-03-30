From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] team: team should sync the port's uc/mc addrs
 when add a port
Date: Wed, 30 Mar 2016 17:07:12 -0400 (EDT)
Message-ID: <20160330.170712.1708636507092918184.davem@davemloft.net>
References: <e7eed00cdf5b0bf2d7eda4364f0fd28e95028db8.1459306719.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	marcelo.leitner@gmail.com, xiyou.wangcong@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbcC3VHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 17:07:15 -0400
In-Reply-To: <e7eed00cdf5b0bf2d7eda4364f0fd28e95028db8.1459306719.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 30 Mar 2016 10:58:39 +0800

> There is an issue when we use mavtap over team:
> When we replug nic links from team0, the real nics's mc list will not
> include the maddr for macvtap any more. then we can't receive pkts to
> macvtap device, as they are filterred by mc list of nic.
> 
> In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().
> 
> We will fix this issue on team by adding the port's uc/mc addrs sync in
> team_port_add.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
