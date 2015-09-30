From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 12:20:46 -0400
Message-ID: <20150930162046.GB2627@mtj.duckdns.org>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
 <20150930161925.GJ32625@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33347 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbbI3QUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 12:20:52 -0400
Content-Disposition: inline
In-Reply-To: <20150930161925.GJ32625@saruman.tx.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 11:19:25AM -0500, Felipe Balbi wrote:
> On Mon, Sep 28, 2015 at 03:35:14PM +0200, Christoph Hellwig wrote:
> > On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> > > this (and the other helper below) could be macros just fine.
> > 
> > They could, but they shouldn't.  Inlines are always preferable over
> > function-like macros.
> 
> says who ? And why ?

Documentation/CodingStyle

-- 
tejun
