From: Christoph Hellwig <hch@infradead.org>
Subject: Re: cfg80211/nl80211/WE (was: Re: d80211 merge)
Date: Thu, 2 Nov 2006 10:56:39 +0000
Message-ID: <20061102105639.GA714@infradead.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <45493C09.9050707@garzik.org> <45494E51.7070707@linux.intel.com> <45495E27.6090500@garzik.org> <1162457341.3241.15.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
Received: from pentafluge.infradead.org ([213.146.154.40]:50087 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1752829AbWKBLAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 06:00:54 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1162457341.3241.15.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 09:49:01AM +0100, Johannes Berg wrote:
> I'm pretty sure I've said this like a dozen times but apparently it
> hasn't sunk in yet:
> 
> The latest cfg80211/nl80211 code comes with WE compatibility code that
> users can disable if they want to, which, however, gives them the
> ability to use WE in userspace while the drivers are happily using
> cfg80211.
> 
> My goal is to remove WE from *all* drivers, even from the ancient
> pre-802.11 and early 802.11 fullmac drivers, and leave WE merely as
> another userspace interface for cfg80211, albeit with limitations that
> the netlink interface nl80211 doesn't have.

Yes, that is exatly the right way to go forward.  The userspace interface
is however more than just the WE ioctls.  It's also that for every wireless
card one single ethX device appears and not multiple devices with other
names.  This might sound like nitpicking, but without this all kinds of
scripts break.

