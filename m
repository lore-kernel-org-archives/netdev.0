From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Do not use private netdev_vport
 fields
Date: Tue, 06 Jan 2015 17:01:16 -0500 (EST)
Message-ID: <20150106.170116.1035144706028544996.davem@davemloft.net>
References: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: daniele.di.proietto@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbbAFWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:01:18 -0500
In-Reply-To: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Date: Tue,  6 Jan 2015 21:51:21 +0100

> This commit introduces netdev_vport_index() to prevent datapath.c from directly accessing the 'dev' member of 'struct netdev_vport'.
> This fix is needed to allow possible alternative netdev_vport implementations.
> 
> Signed-off-by: Daniele Di Proietto <daniele.di.proietto@gmail.com>

This doesn't make any sense to me, as the code currently stands your
change is not necessary at all.

If some need does arise, submit this patch along with the change
that creates the need.
