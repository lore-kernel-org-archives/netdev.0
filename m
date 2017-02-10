From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] afs: Use system UUID generation
Date: Fri, 10 Feb 2017 16:46:12 +0000
Message-ID: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is now a general function for generating a UUID and AFS should make
use of it.  It's also been recommended to me that I switch to using random
rather than time plus MAC address-based UUIDs which this function does.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170210

David
---
Arnd Bergmann (1):
      afs: Use core kernel UUID generation

David Howells (1):
      afs: Move UUID struct to linux/uuid.h


 fs/afs/cmservice.c   |   28 ++++++++++++++--------------
 fs/afs/internal.h    |   38 +++++++-------------------------------
 fs/afs/main.c        |   49 ++-----------------------------------------------
 fs/afs/netdevices.c  |   21 ---------------------
 include/linux/uuid.h |   24 ++++++++++++++++++++++++
 5 files changed, 47 insertions(+), 113 deletions(-)
