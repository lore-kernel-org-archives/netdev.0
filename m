From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
Date: Wed, 16 Apr 2014 09:00:02 -0400 (EDT)
Message-ID: <20140416.090002.2186526865564557549.davem@davemloft.net>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.96000.stgit@notabene.brown>
	<1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: neilb@suse.de, linux-mm@kvack.org, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Apr 2014 22:13:46 -0700

> For applications handling millions of sockets, this makes a difference.

Indeed, this really is not acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
