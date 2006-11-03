From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [take3 0/5] d80211: remove bitfields from include/net/d80211.h
Date: Thu, 2 Nov 2006 22:30:56 -0500
Message-ID: <20061103033049.GD2989@tuxdriver.com>
References: <20061025184244.GA30046@devicescape.com> <20061025190129.GH19513@havoc.gtf.org> <20061025191702.GA32410@devicescape.com> <20061025192803.GJ19513@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:8973 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1753034AbWKCDys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 22:54:48 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061025192803.GJ19513@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 03:28:03PM -0400, Jeff Garzik wrote:
> On Wed, Oct 25, 2006 at 12:17:02PM -0700, David Kimdon wrote:
> > That is how I originally had the patch, but then had a question about
> > increasing structure size so I dropped flags to u16 or u8 for
> > structures that were made larger by the bitfield removal.
> 
> On non-x86 platforms, u16 and u8 generate shitty code too.  Not as
> shitty as bitfields, but still shitty.

David, may I presume there will be a "take4"?

John
-- 
John W. Linville
linville@tuxdriver.com
