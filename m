From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take3 0/5] d80211: remove bitfields from include/net/d80211.h
Date: Wed, 25 Oct 2006 15:28:03 -0400
Message-ID: <20061025192803.GJ19513@havoc.gtf.org>
References: <20061025184244.GA30046@devicescape.com> <20061025190129.GH19513@havoc.gtf.org> <20061025191702.GA32410@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:5518 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1422778AbWJYT2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 15:28:04 -0400
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061025191702.GA32410@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 12:17:02PM -0700, David Kimdon wrote:
> That is how I originally had the patch, but then had a question about
> increasing structure size so I dropped flags to u16 or u8 for
> structures that were made larger by the bitfield removal.

On non-x86 platforms, u16 and u8 generate shitty code too.  Not as
shitty as bitfields, but still shitty.

	Jeff



