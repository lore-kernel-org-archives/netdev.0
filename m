From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH net v6] xen-netfront: fix resource leak in
 netfront
Date: Mon, 27 Jan 2014 19:49:19 -0800 (PST)
Message-ID: <20140127.194919.2002640193008432431.davem@davemloft.net>
References: <1390880142-4962-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, david.vrabel@citrix.com
To: Annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbaA1DtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 22:49:22 -0500
In-Reply-To: <1390880142-4962-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <Annie.li@oracle.com>
Date: Tue, 28 Jan 2014 11:35:42 +0800

> This patch removes grant transfer releasing code from netfront, and uses
> gnttab_end_foreign_access to end grant access since
> gnttab_end_foreign_access_ref may fail when the grant entry is
> currently used for reading or writing.

Applied and queued up for -stable, thanks.
