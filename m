From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net/mlx4: Add dynamic policy changes to
 the SRIOV eSwitch support
Date: Mon, 01 Jul 2013 13:12:55 -0700 (PDT)
Message-ID: <20130701.131255.894732078933976198.davem@davemloft.net>
References: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	ronye@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624Ab3GAUM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:12:59 -0400
In-Reply-To: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 27 Jun 2013 19:05:20 +0300

> This patch set from Jack and Rony uses the UPDATE_QP new firmware command 
> to allow for dynamic policy changes of PF controlled VF vlan/qos and link-state.
> 
> Done against net-next commit 8599b52e14 "bonding: add an option to fail when any 
> of arp_ip_target is inaccessible"

Applied, but in patch #2:

+		/* even if the UPDATE_QP command isn't supported, we still want
+ 		 * to set this VF link according to the admin directive
+ 		 */

Those last two lines start with a space, then TAB(s), which I had to
fix up.  GIT even warns about this when I apply your patches.
