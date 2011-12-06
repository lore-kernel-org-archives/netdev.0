From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netback: remove redundant assignment
Date: Tue, 06 Dec 2011 13:14:49 -0500 (EST)
Message-ID: <20111206.131449.1351676944529284449.davem@davemloft.net>
References: <1323166100-7059-1-git-send-email-wei.liu2@citrix.com>
	<1323166882.23681.46.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab1LFSO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:14:56 -0500
In-Reply-To: <1323166882.23681.46.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 6 Dec 2011 10:21:22 +0000

> On Tue, 2011-12-06 at 10:08 +0000, Wei Liu wrote:
>> New value for netbk->mmap_pages[pending_idx] is assigned in
>> xen_netbk_alloc_page(), no need for a second assignment which
>> exposes internal to the outside world.
>> 
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied to net-next, thanks.
