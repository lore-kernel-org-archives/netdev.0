From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] afs: Conditionalise a new unused variable
Date: Mon, 16 Jan 2017 13:31:17 -0500 (EST)
Message-ID: <20170116.133117.2240643249072761154.davem@davemloft.net>
References: <148431877922.23745.3756091538832610041.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAPSbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:31:19 -0500
In-Reply-To: <148431877922.23745.3756091538832610041.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 13 Jan 2017 14:46:19 +0000

> From: Arnd Bergmann <arnd@arndb.de>
> 
> The bulk readpages support introduced a harmless warning:
> 
> fs/afs/file.c: In function 'afs_readpages_page_done':
> fs/afs/file.c:270:20: error: unused variable 'vnode' [-Werror=unused-variable]
> 
> This adds an #ifdef to match the user of that variable.  The user of the
> variable has to be conditional because it accesses a member of a struct
> that is also conditional.
> 
> Fixes: 91b467e0a3f5 ("afs: Make afs_readpages() fetch data in bulk")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
