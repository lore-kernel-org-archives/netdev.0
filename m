From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Date: Mon, 12 Sep 2011 11:04:45 +0200
Message-ID: <1315818285.26517.18.camel@twins>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
	 <1315566054-17209-4-git-send-email-mgorman@suse.de>
	 <20110909130007.GA11810@infradead.org> <20110909131550.GV14369@suse.de>
	 <20110909133611.GB8155@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>,
 Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS
 <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>,  David Miller <davem@davemloft.net>,
 Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110909133611.GB8155@infradead.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> The equivalent of ->direct_IO should be used for both reads and writes.

So the difference between DIO and swapIO is that swapIO needs the block
map pinned in memory.. So at the very least you'll need those
swap_{activate,deactivate} aops. The read/write-page thingies could
indeed be shared with DIO.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
