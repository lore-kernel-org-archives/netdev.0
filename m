From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 12:35:38 -0400
Message-ID: <20150930163538.GC2627@mtj.duckdns.org>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
 <20150930161925.GJ32625@saruman.tx.rr.com>
 <20150930162046.GB2627@mtj.duckdns.org>
 <20150930163219.GN32625@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150930163219.GN32625@saruman.tx.rr.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:32:19AM -0500, Felipe Balbi wrote:
> On Wed, Sep 30, 2015 at 12:20:46PM -0400, Tejun Heo wrote:
> > On Wed, Sep 30, 2015 at 11:19:25AM -0500, Felipe Balbi wrote:
> > > On Mon, Sep 28, 2015 at 03:35:14PM +0200, Christoph Hellwig wrote:
> > > > On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> > > > > this (and the other helper below) could be macros just fine.
> > > > 
> > > > They could, but they shouldn't.  Inlines are always preferable over
> > > > function-like macros.
> > > 
> > > says who ? And why ?
> > 
> > Documentation/CodingStyle
> 
> container_of() is type-safe, what is an inline function bringing as benefit ?

It's a general preference.  Because there's enough benefit to going
with inline functions and there's extra benefit to be gained from
having consistent style of code and documentation, as a general rule,
we prefer inline functions over macros.  If you have specific
technical arguments why macro is better, sure; otherwise, follow the
conventions for consistency if for nothing else.

-- 
tejun
