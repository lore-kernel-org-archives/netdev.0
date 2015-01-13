From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH 08/14] xen-netback: use foreign page
 information from the pages themselves
Date: Tue, 13 Jan 2015 16:57:16 -0500 (EST)
Message-ID: <20150113.165716.1890765871642205972.davem@davemloft.net>
References: <1421077417-7162-1-git-send-email-david.vrabel@citrix.com>
	<1421077417-7162-9-git-send-email-david.vrabel@citrix.com>
	<54B52F1B.8040408@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com,
	jennifer.herbert@citrix.com, netdev@vger.kernel.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbAMV5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:57:18 -0500
In-Reply-To: <54B52F1B.8040408@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 13 Jan 2015 14:43:39 +0000

> On 12/01/15 15:43, David Vrabel wrote:
>> From: Jenny Herbert <jenny.herbert@citrix.com>
>> 
>> Use the foreign page flag in netback to get the domid and grant ref
>> needed for the grant copy.  This signficiantly simplifies the netback
>> code and makes netback work with foreign pages from other backends
>> (e.g., blkback).
>> 
>> This allows blkback to use iSCSI disks provided by domUs running on
>> the same host.
> 
> Dave,
> 
> This depends on several xen changes.  It's been Acked-by: Ian Campbell
> <ian.campbell@citrix.com>
> 
> Are you happy for me to merge this via the xen tree in 3.20?

No objections from me:

Acked-by: David S. Miller <davem@davemloft.net>
