From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Fix potential NULL-pointer exception
Date: Fri, 03 Mar 2017 09:48:40 -0800 (PST)
Message-ID: <20170303.094840.541547905439932719.davem@davemloft.net>
References: <148849717388.26285.3477243497908119377.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdCCSQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:16:43 -0500
In-Reply-To: <148849717388.26285.3477243497908119377.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Thu, 02 Mar 2017 23:26:13 +0000

> Fix a potential NULL-pointer exception in rxrpc_do_sendmsg().  The call
> state check that I added should have gone into the else-body of the
> if-statement where we actually have a call to check.
> 
> Found by CoverityScan CID#1414316 ("Dereference after null check").
> 
> Fixes: 540b1c48c37a ("rxrpc: Fix deadlock between call creation and sendmsg/recvmsg")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
