From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6 merged into net-next-2.6
Date: Tue, 10 Jun 2008 12:02:12 -0400
Message-ID: <20080610160212.GA16834@tuxdriver.com>
References: <20080610.025059.37807108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4139 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668AbYFJQ37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 12:29:59 -0400
Content-Disposition: inline
In-Reply-To: <20080610.025059.37807108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 02:50:59AM -0700, David Miller wrote:
> 
> There were a few small wireless conflicts but I think
> I handled them correctly.
> 
> Please send me any fixup patches which might be necessary.

Just one, which was easy to miss:

The following changes since commit 65b53e4cc90e59936733b3b95b9451d2ca47528d:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git
master

John W. Linville (1):
      rt2x00dev.c: fix-up merge damage

 drivers/net/wireless/rt2x00/rt2x00dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index f7a4417..dc5ab90 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -507,7 +507,7 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	rt2x00dev->link.qual.tx_success +=
 	    test_bit(TXDONE_SUCCESS, &txdesc->flags);
 	rt2x00dev->link.qual.tx_failed +=
-	    txdesc->retry + !!test_bit(TXDONE_FAILURE, &txdesc->flags);
+	    test_bit(TXDONE_FAILURE, &txdesc->flags);
 
 	/*
 	 * Initialize TX status
-- 
John W. Linville
linville@tuxdriver.com
