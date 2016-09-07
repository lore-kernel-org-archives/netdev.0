From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] rxrpc: Local abort tracepoint
Date: Wed, 07 Sep 2016 16:39:42 +0100
Message-ID: <147326277574.9308.4656891674085539944.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are two patches.  They need to be applied on top of the just-posted
call refcount overhaul patch:

 (1) Fix the return value of some call completion helpers.

 (2) Add a tracepoint that allows local aborts to be debugged.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160904-2

David
---
David Howells (2):
      rxrpc: Fix returns of call completion helpers
      rxrpc: Add tracepoint for working out where aborts happen


 fs/afs/rxrpc.c               |   17 ++++---
 include/net/af_rxrpc.h       |    3 +
 include/trace/events/rxrpc.h |   29 +++++++++++
 net/rxrpc/ar-internal.h      |   27 +++++++----
 net/rxrpc/call_event.c       |    7 ++-
 net/rxrpc/call_object.c      |    2 -
 net/rxrpc/conn_event.c       |    6 ++
 net/rxrpc/input.c            |    7 ++-
 net/rxrpc/insecure.c         |   19 ++++---
 net/rxrpc/rxkad.c            |  108 +++++++++++++++++++-----------------------
 net/rxrpc/sendmsg.c          |   18 ++++---
 11 files changed, 140 insertions(+), 103 deletions(-)
