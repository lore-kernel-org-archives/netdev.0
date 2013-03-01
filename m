From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] Provide default fdb operation to allow
 mac filter setting
Date: Fri, 01 Mar 2013 16:26:12 -0500 (EST)
Message-ID: <20130301.162612.2115492006742815404.davem@davemloft.net>
References: <1362151906-20993-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab3CAV0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 16:26:14 -0500
In-Reply-To: <1362151906-20993-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri,  1 Mar 2013 10:31:42 -0500

> This is a short series that now allows mac filter programming on any
> card that support IFF_UNICAST_FLT by using the existing FDB interface.
> 
> Some existing drivers that had FDB functionality usually supported
> it only in SR-IOV mode.  Since that's not always enabled, and
> we want to take advantage of IFF_UNICAST_FLT support, these drivers
> have been converted to call the default handler when not in SRIOV mode.

These changes look great, please resubmit them once I open net-next
back up.

Thanks.
