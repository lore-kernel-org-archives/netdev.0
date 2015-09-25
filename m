From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 01/23] configfs: add show and store methods to struct
 configfs_attribute
Date: Fri, 25 Sep 2015 10:41:06 -0700
Message-ID: <20150925174106.GA1402@kroah.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-2-git-send-email-hch@lst.de>
 <20150925142857.GA4449@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:34227 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673AbbIYRlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 13:41:08 -0400
Content-Disposition: inline
In-Reply-To: <20150925142857.GA4449@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 10:28:57AM -0400, Tejun Heo wrote:
> Hello, Christoph.
> 
> On Fri, Sep 25, 2015 at 06:49:38AM -0700, Christoph Hellwig wrote:
> > Add methods to struct configfs_attribute to directly show and store
> > attributes without adding boilerplate code to every user.  In addition
> > to the methods this also adds 3 helper macros to define read/write,
> > read-only and write-only attributes with a single line of code.
> 
> This looks great to me.  It doesn't look like the whole attribute
> thing played out as hoped.  It'd be great if we can move away from it.
> 
> Thanks a lot for the work!

Looks good to me as well, no objection from my side for the USB or core
configfs stuff:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
