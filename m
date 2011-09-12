From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Date: Mon, 12 Sep 2011 10:34:34 +0100
Message-ID: <20110912093058.GA3207@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
 <20110909130007.GA11810@infradead.org>
 <20110909131550.GV14369@suse.de>
 <20110909133611.GB8155@infradead.org>
 <1315818285.26517.18.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Linux-MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Linux-Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-NFS <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1315818285.26517.18.camel@twins>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2011 at 11:04:45AM +0200, Peter Zijlstra wrote:
> On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> > The equivalent of ->direct_IO should be used for both reads and writes.
> 
> So the difference between DIO and swapIO is that swapIO needs the block
> map pinned in memory.. So at the very least you'll need those
> swap_{activate,deactivate} aops. The read/write-page thingies could
> indeed be shared with DIO.
> 

I'm travelling at the moment so it'll be later in the week when I investigate
properly but I agree swap_[de|a]ctivate are still necessary. NFS does not
need to pin a block map but it's still necessary for calling xs_set_memalloc.

-- 
Mel Gorman
SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
