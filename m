From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] rxrpc: Rename rxrpc source files
Date: Mon, 13 Jun 2016 15:07:50 +0100
Message-ID: <146582687035.9344.8429200604453755089.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Here's the next part of the AF_RXRPC rewrite.  In this set I rename some of
the files in the net/rxrpc/ directory and adjust the Makefile and
ar-internal.h to reflect the changes.

The aim is twofold:

 (1) Remove the "ar-" prefix on those files that have it as it's not really
     useful, especially now that I'm building rxkad in.

 (2) To aid splitting the local, peer, connection and call handling code
     into separate files for object and event handling in future patches by
     making it easier to come up with new filenames.

There are two commits:

 (1) The first commit does a bunch of renames of .c files and alters the
     Makefile.  ar-internal.h isn't renamed at this time to avoid having to
     change the contents of the files being renamed.

 (2) The second commit changes the section label comments in ar-internal.h
     to reflect the changed filenames and reorders the file so that the
     sections are back in filename order.


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160613


David
---
David Howells (2):
      rxrpc: Rename files matching ar-*.c to git rid of the "ar-" prefix
      rxrpc: Update the comments in ar-internal.h to reflect renames


 net/rxrpc/Makefile        |   34 ++++++-----
 net/rxrpc/ar-internal.h   |  138 +++++++++++++++++++++++----------------------
 net/rxrpc/call_accept.c   |    0 
 net/rxrpc/call_event.c    |    0 
 net/rxrpc/call_object.c   |    0 
 net/rxrpc/conn_event.c    |    0 
 net/rxrpc/conn_object.c   |    0 
 net/rxrpc/input.c         |    0 
 net/rxrpc/key.c           |    0 
 net/rxrpc/local_object.c  |    0 
 net/rxrpc/output.c        |    0 
 net/rxrpc/peer_event.c    |    0 
 net/rxrpc/peer_object.c   |    0 
 net/rxrpc/proc.c          |    0 
 net/rxrpc/recvmsg.c       |    0 
 net/rxrpc/security.c      |    0 
 net/rxrpc/skbuff.c        |    0 
 net/rxrpc/transport.c     |    0 
 18 files changed, 86 insertions(+), 86 deletions(-)
 rename net/rxrpc/{ar-accept.c => call_accept.c} (100%)
 rename net/rxrpc/{ar-ack.c => call_event.c} (100%)
 rename net/rxrpc/{ar-call.c => call_object.c} (100%)
 rename net/rxrpc/{ar-connevent.c => conn_event.c} (100%)
 rename net/rxrpc/{ar-connection.c => conn_object.c} (100%)
 rename net/rxrpc/{ar-input.c => input.c} (100%)
 rename net/rxrpc/{ar-key.c => key.c} (100%)
 rename net/rxrpc/{ar-local.c => local_object.c} (100%)
 rename net/rxrpc/{ar-output.c => output.c} (100%)
 rename net/rxrpc/{ar-error.c => peer_event.c} (100%)
 rename net/rxrpc/{ar-peer.c => peer_object.c} (100%)
 rename net/rxrpc/{ar-proc.c => proc.c} (100%)
 rename net/rxrpc/{ar-recvmsg.c => recvmsg.c} (100%)
 rename net/rxrpc/{ar-security.c => security.c} (100%)
 rename net/rxrpc/{ar-skbuff.c => skbuff.c} (100%)
 rename net/rxrpc/{ar-transport.c => transport.c} (100%)
