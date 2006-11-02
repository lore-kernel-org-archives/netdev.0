From: Johannes Berg <johannes@sipsolutions.net>
Subject: cfg80211/nl80211/WE (was: Re: d80211 merge)
Date: Thu, 02 Nov 2006 09:49:01 +0100
Message-ID: <1162457341.3241.15.camel@ux156>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <45493C09.9050707@garzik.org> <45494E51.7070707@linux.intel.com>
	 <45495E27.6090500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:6578 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752745AbWKBIvS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 03:51:18 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45495E27.6090500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-01 at 21:55 -0500, Jeff Garzik wrote:

> Speaking specifically, Linus noted recently d80211 should maintain 
> backwards compatibility with the WE userspace ABI, so that existing 
> wireless tools keep working, and I definitely agree.  For additional 
> functionality/flexibility, I presume there will be some sort of netlink 
> extensible interface (cfg80211 I think?) that newer wireless tools will 
> use.  In time, the WE back-compat ABI could become an optional module 
> that users can disable.

I'm pretty sure I've said this like a dozen times but apparently it
hasn't sunk in yet:

The latest cfg80211/nl80211 code comes with WE compatibility code that
users can disable if they want to, which, however, gives them the
ability to use WE in userspace while the drivers are happily using
cfg80211.

My goal is to remove WE from *all* drivers, even from the ancient
pre-802.11 and early 802.11 fullmac drivers, and leave WE merely as
another userspace interface for cfg80211, albeit with limitations that
the netlink interface nl80211 doesn't have.

Until all drivers are converted, however, cfg80211-WE and regular WE
coexist peacefully, it is even possible to convert one ioctl at a time
over to cfg80211 (which is only really useful while working at it, but
still).

johannes
