From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 01/23] configfs: add show and store methods to struct
 configfs_attribute
Date: Fri, 25 Sep 2015 10:28:57 -0400
Message-ID: <20150925142857.GA4449@mtj.duckdns.org>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-2-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34017 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295AbbIYO3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:29:03 -0400
Content-Disposition: inline
In-Reply-To: <1443189000-13398-2-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Christoph.

On Fri, Sep 25, 2015 at 06:49:38AM -0700, Christoph Hellwig wrote:
> Add methods to struct configfs_attribute to directly show and store
> attributes without adding boilerplate code to every user.  In addition
> to the methods this also adds 3 helper macros to define read/write,
> read-only and write-only attributes with a single line of code.

This looks great to me.  It doesn't look like the whole attribute
thing played out as hoped.  It'd be great if we can move away from it.

Thanks a lot for the work!

-- 
tejun
