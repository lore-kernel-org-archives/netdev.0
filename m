From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: mdb: add vlan support for user entries
Date: Mon, 13 Jul 2015 14:41:40 -0700 (PDT)
Message-ID: <20150713.144140.2082284542914664511.davem@davemloft.net>
References: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbGMVll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 17:41:41 -0400
In-Reply-To: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 10 Jul 2015 08:02:08 -0700

> Until now all user mdb entries were added in vlan 0, this patch adds
> support to allow the user to specify the vlan for the entry.
> About the uapi change a hole in struct br_mdb_entry is used so the size
> and offsets are kept the same (verified with pahole and tested with older
> iproute2).
> 
> Example:
> $ bridge mdb
> dev br0 port eth1 grp 239.0.0.1 permanent vlan 2000
> dev br0 port eth1 grp 239.0.0.1 permanent vlan 200
> dev br0 port eth1 grp 239.0.0.1 permanent
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This looks ok, applied thanks Nikolay.
