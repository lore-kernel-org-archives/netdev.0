From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [take1 0/5] d80211 patches
Date: Wed, 18 Oct 2006 10:38:10 -0700
Message-ID: <20061018173810.GA30457@devicescape.com>
References: <20061017171713.GA13669@devicescape.com> <20061018180131.556fe5bc@griffin.suse.cz> <20061018172009.GA25808@devicescape.com> <200610181923.14370.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:37027 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751495AbWJRRiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 13:38:16 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200610181923.14370.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 07:23:14PM +0200, Ivo van Doorn wrote:
> On Wednesday 18 October 2006 19:20, David Kimdon wrote:
> > On Wed, Oct 18, 2006 at 06:01:31PM +0200, Jiri Benc wrote:
> > > On Tue, 17 Oct 2006 10:17:13 -0700, David Kimdon wrote:
> > > > Continue d80211 bitfield removal.  In general, compilers have
> > > > difficulty generating efficient code for bitfields.  This patchset
> > > > removes all bitfields from include/net/d80211.h.
> > > 
> > > Thanks for the patches! At first I intended to ask you to split d80211
> > > and drivers parts of the patches, but your way is better I think - it
> > > doesn't break git-bisect.
> > > 
> > > John, if you agree with these patches, could you apply them after you
> > > pull from my tree?
> > 
> > hold that thought, I missed updating rt73usb.c and rt2500usb.c.  New
> > patchset on its way.
> 
> Hi,
> 
> That patch was send 2 hours ago by me to this list. :)
> "[PATCH] rt2x00: Remove xr_end references"
> That patch only fixed rt2500usb and rt73usb, so it can be applied safely
> after your patch to fix the rt2x00 PCI drivers. 

Sorry, to be clear, I am talking about the bitfield removal from
d80211.h patches.  Actually, your patch to remove the xr references
from the usb drivers is what made me notice I had forgotten them from
the bitfield removal patches.

hmm, I have a bad subject to the first mail in my post, my posting
script set the initial 0/5 message subject as 'd80211 patches', should
probably be a bit more specific :-)

-David
