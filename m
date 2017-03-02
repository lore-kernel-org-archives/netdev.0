From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net] rxrpc: Fix potential NULL-pointer exception
Date: Thu, 02 Mar 2017 23:30:45 +0000
Message-ID: <26697.1488497445@warthog.procyon.org.uk>
References: <148849717388.26285.3477243497908119377.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148849717388.26285.3477243497908119377.stgit@warthog.procyon.org.uk>
Content-ID: <26696.1488497445.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> Fix a potential NULL-pointer exception in rxrpc_do_sendmsg().  The call
> state check that I added should have gone into the else-body of the
> if-statement where we actually have a call to check.
> 
> Found by CoverityScan CID#1414316 ("Dereference after null check").
> 
> Fixes: 540b1c48c37a ("rxrpc: Fix deadlock between call creation and sendmsg/recvmsg")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Please ignore this - there's another patch interposed that I haven't sent
upstream yet.  Will rebase on net/master.

David
