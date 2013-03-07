From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 resent net-next 0/4] Provide default fdb operation
 to allow mac filter setting
Date: Thu, 07 Mar 2013 15:30:19 -0500 (EST)
Message-ID: <20130307.153019.1916003215764923222.davem@davemloft.net>
References: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, or.gerlitz@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933270Ab3CGUaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:30:21 -0500
In-Reply-To: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed,  6 Mar 2013 20:39:41 -0500

> This is a short series that now allows mac filter programming on any
> card that support IFF_UNICAST_FLT by using the existing FDB interface.
> 
> Some existing drivers that had FDB functionality usually supported
> it only in SR-IOV mode.  Since that's not always enabled, and
> we want to take advantage of IFF_UNICAST_FLT support, these drivers
> have been converted to call the default handler when not in SRIOV mode.

Series applied, thanks Vlad.
