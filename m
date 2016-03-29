From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] team: team should sync the port's uc/mc addrs when
 add a port
Date: Tue, 29 Mar 2016 00:22:57 -0400 (EDT)
Message-ID: <20160329.002257.534415260245036162.davem@davemloft.net>
References: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, marcelo.leitner@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbcC2EXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 00:23:00 -0400
In-Reply-To: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 29 Mar 2016 00:42:31 +0800

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

Applied, thank you.
