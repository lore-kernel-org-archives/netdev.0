From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] afs: Implement bulk read
Date: Fri, 06 Jan 2017 17:08:40 +0000
Message-ID: <148372251997.8578.5117118854142528477.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030424AbdAFRIm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 12:08:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This pair of patches implements bulk data reading from an AFS server.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170106

David
---
David Howells (2):
      afs: Make afs_fs_fetch_data() take a list of pages
      afs: Make afs_readpages() fetch data in bulk


 fs/afs/file.c     |  168 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/afs/fsclient.c |  117 ++++++++++++++++++++++++-------------
 fs/afs/internal.h |   21 ++++++-
 fs/afs/vnode.c    |    6 +-
 fs/afs/volume.c   |    1 
 fs/afs/write.c    |   19 +++++-
 6 files changed, 275 insertions(+), 57 deletions(-)
