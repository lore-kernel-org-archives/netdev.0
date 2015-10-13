From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: simplify configfs attributes V2
Date: Tue, 13 Oct 2015 14:54:33 +0200
Message-ID: <20151013125433.GA18474@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de> <20151005143705.bdcfa7d7b8211506c5dbc12e@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>,
	Nicholas Bellinger <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pratyush Anand <pratyush.anand-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
	target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151005143705.bdcfa7d7b8211506c5dbc12e-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 05, 2015 at 02:37:05PM -0700, Andrew Morton wrote:
> > This series consolidates the code to implement configfs attributes
> > by providing the ->show and ->store method in common code and using
> > container_of in the methods to access the containing structure.
> > 
> > This reduces source and binary size of configfs consumers a lot.
> 
> There's a version of this patch series (I assume V1) in linux-next via
> Nicholas's tree so my hands are tied.  I trust that Nicholas will
> update things.
> 
> Or maybe it was a slipup - modifying usb, ocfs2 etc from the iscsi tree
> is innovative ;)

Nic wanted this as the target code is the biggest user of configfs.
I don't really care where it goes as long as we get in the current version
into a stable not to be rebased branch somehwere so that all consumers
can use that as a base point.

Nic, can you do that?  A lot of previous work went in through Andrew, but I
think -mm is still a quilt stack so the stable base branch wouldn't be
possible that way.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
