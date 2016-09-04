From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/3] rxrpc: Split output code from sendmsg code
Date: Sun, 04 Sep 2016 22:04:12 +0100
Message-ID: <147302305256.28850.16735273264737276926.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754212AbcIDVEV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 17:04:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a set of small patches that split the packet transmission code from
the sendmsg code and simply rearrange the new file to make it more
logically laid out ready for being rewritten.  An enum is also moved out of
the header file to there as it's only used there.  This needs to be applied
on top of the just-posted fixes patch set.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160904-2

David
---
David Howells (3):
      rxrpc: Split sendmsg from packet transmission code
      rxrpc: Rearrange net/rxrpc/sendmsg.c
      rxrpc Move enum rxrpc_command to sendmsg.c


 net/rxrpc/Makefile      |    1 
 net/rxrpc/ar-internal.h |   16 -
 net/rxrpc/misc.c        |    5 
 net/rxrpc/output.c      |  630 ----------------------------------------------
 net/rxrpc/sendmsg.c     |  648 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 660 insertions(+), 640 deletions(-)
 create mode 100644 net/rxrpc/sendmsg.c
