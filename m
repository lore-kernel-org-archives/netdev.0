From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/43] drivers/net/bonding: fix sparse warnings:
 context imbalance
Date: Tue, 17 Feb 2009 17:27:01 -0800 (PST)
Message-ID: <20090217.172701.10220214.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211525.23489.61644.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54463
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756056AbZBRB1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:27:17 -0500
In-Reply-To: <20090214211525.23489.61644.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:15:33 +0100

> Impact: Attribute functions with __acquires(...) and/or __releases(...).
> 
> Fix this sparse warnings:
>   drivers/net/bonding/bond_alb.c:1675:9: warning: context imbalance in 'bond_alb_handle_active_change' - unexpected unlock
>   drivers/net/bonding/bond_alb.c:1742:9: warning: context imbalance in 'bond_alb_set_mac_address' - unexpected unlock
>   drivers/net/bonding/bond_main.c:1025:17: warning: context imbalance in 'bond_do_fail_over_mac' - unexpected unlock
>   drivers/net/bonding/bond_main.c:3195:13: warning: context imbalance in 'bond_info_seq_start' - wrong count at exit
>   drivers/net/bonding/bond_main.c:3234:13: warning: context imbalance in 'bond_info_seq_stop' - unexpected unlock
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
