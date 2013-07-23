From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 V2] vxlan fdb replace an existing entry
Date: Tue, 23 Jul 2013 16:36:35 -0700 (PDT)
Message-ID: <20130723.163635.1418496776410988221.davem@davemloft.net>
References: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: tmricht@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933968Ab3GWXgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 19:36:38 -0400
In-Reply-To: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Date: Fri, 19 Jul 2013 17:20:07 +0200

> Add support to replace an existing entry found in the
> vxlan fdb database. The entry in question is identified
> by its unicast mac address and the destination information
> is changed. If the entry is not found, it is added in the
> forwarding database. This is similar to changing an entry
> in the neighbour table.
> 
> Multicast mac addresses can not be changed with the replace
> option.
> 
> This is useful for virtual machine migration when the
> destination of a target virtual machine changes. The replace
> feature can be used instead of delete followed by add.
> 
> Resubmitted because net-next was closed last week.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>

Applied.
