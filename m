From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take3 0/5] d80211: remove bitfields from include/net/d80211.h
Date: Wed, 25 Oct 2006 15:01:29 -0400
Message-ID: <20061025190129.GH19513@havoc.gtf.org>
References: <20061025184244.GA30046@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:12173 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1030199AbWJYTBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 15:01:30 -0400
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061025184244.GA30046@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 11:42:44AM -0700, David Kimdon wrote:
> Continue d80211 bitfield removal.  In general, compilers have
> difficulty generating efficient code for bitfields.  This patchset
> removes all bitfields from include/net/d80211.h.
> 
> I converted the 1 bit bitfields into a bit in a u32/u16 or u8 flags
> structure member.  Larger bitfields I converted into their
> u8/u16/whatever equivalent.

For bit flags, usually it is best to use up to 32 bits of an
unsigned long, which guarantees that you use a machine integer for
all platforms.

	Jeff



