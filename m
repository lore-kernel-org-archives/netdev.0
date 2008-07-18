From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support
	for device classes.
Date: Fri, 18 Jul 2008 11:49:36 -0700
Message-ID: <20080718184936.GA21343@suse.de>
References: <m1mykyh2fu.fsf_-_@frodo.ebiederm.org> <m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com> <m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com> <20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org> <487D6A24.9070001@gmail.com> <20080717230857.GB28377@suse.de> <48808F79.7080607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:36533 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758708AbYGRS4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 14:56:18 -0400
Content-Disposition: inline
In-Reply-To: <48808F79.7080607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 09:41:29PM +0900, Tejun Heo wrote:
> Greg KH wrote:
> > Ok, I'll work to get these in where applicable.
> 
> Did this get into 2.6.27?  Or will this have to wait till .28?

I haven't sent any patches to Linus yet for 2.6.27, so it hasn't gotten
there yet.

And due to the intrusiveness, and the fact that this hasn't been tested
at all in any build tree yet, I can't in good concious submit this for
.27 either.

Part of this is my fault, I know, due to vacation and work, but also
lots is due to the fact that the code showed up so late in the
development cycle.

I'll add it to my tree, and get it some testing in the next cycle of
linux-next until 2.6.27 is out, and then if it's still looking good, go
into .28.

Hope this helps,

greg k-h
