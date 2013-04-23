From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 2/2] batman-adv: fix global protection fault
 during soft_iface destruction
Date: Mon, 22 Apr 2013 20:41:13 -0400 (EDT)
Message-ID: <20130422.204113.1112043388924796755.davem@davemloft.net>
References: <1366362292-22961-1-git-send-email-ordex@autistici.org>
	<1366362292-22961-3-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab3DWAlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 20:41:14 -0400
In-Reply-To: <1366362292-22961-3-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Fri, 19 Apr 2013 11:04:52 +0200

> batadv_mesh_free() schedules some RCU callbacks which need the bat_priv struct
> to do their jobs, while free_netdev(), which is called immediately after, is
> destroying the private data.
> 
> Put an rcu_barrier() in the middle so that free_netdev() is invoked only after
> all the callbacks returned.
> 
> This bug has been introduced by ab8f433dd39be94e8617cff2dfe9f7eca162eb15
> ("batman-adv: Move deinitialization of soft-interface to destructor")
> 
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>
> Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>

Applied.
