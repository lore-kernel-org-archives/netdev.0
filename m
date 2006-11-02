From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: cfg80211/nl80211/WE (was: Re: d80211 merge)
Date: Thu, 02 Nov 2006 13:03:04 +0100
Message-ID: <1162468984.9431.1.camel@ux156>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <45493C09.9050707@garzik.org> <45494E51.7070707@linux.intel.com>
	 <45495E27.6090500@garzik.org> <1162457341.3241.15.camel@ux156>
	 <20061102105639.GA714@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47766 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752135AbWKBMGQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 07:06:16 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102105639.GA714@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 10:56 +0000, Christoph Hellwig wrote:

> Yes, that is exatly the right way to go forward.  The userspace interface
> is however more than just the WE ioctls.  It's also that for every wireless
> card one single ethX device appears and not multiple devices with other
> names.  This might sound like nitpicking, but without this all kinds of
> scripts break.

cfg80211 doesn't care about that, it only requires you to register one
logical wiphy device. Whether it has more than one netdev or not isn't
significant.

For d80211, however, trying to get rid of the wmasterX interface
requires tighter integration in order to run a qdisc on a non-netdev
wireless physical device. Which gets us back to how this thread
started :)

johannes
