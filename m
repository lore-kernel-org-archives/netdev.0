From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: ipw2100 wireless driver
Date: Wed, 11 Aug 2004 19:02:08 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040811170208.GG10100@louise.pinerecords.com>
References: <20040809201556.GB9677@louise.pinerecords.com> <Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com> <20040810075558.A14154@infradead.org> <20040810101640.GF9034@atrey.karlin.mff.cuni.cz> <4119F203.1070009@linux.intel.com> <20040811114437.A27439@infradead.org> <411A478E.1080101@linux.intel.com> <20040811093043.522cc5a0@dell_ss3.pdx.osdl.net> <20040811163333.GE10100@louise.pinerecords.com> <20040811175105.A30188@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268108AbUHKRCw@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	Pavel Machek <pavel@suse.cz>,
	Jeff Chua <jeffchua@silk.corp.fedex.com>, netdev@oss.sgi.com,
	kernel list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040811175105.A30188@infradead.org>
List-Id: netdev.vger.kernel.org

On Aug-11 2004, Wed, 17:51 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Aug 11, 2004 at 06:33:33PM +0200, Tomas Szepe wrote:
> > There are many people who don't want to mess around with hotplug just
> > to get a single driver to load.
> 
> Then use a distribution that gets it right for you.  Having gazillions
> of diffferent firmware loaders just because people are too lazy to set
> up the canonical one isn't where we want to go.

Agreed.  But the point is, in the actual case of ipw2100, will the removal
of 40 or so lines of code justify killing the functionality for those (lots)
that use it?  I don't think so.  A nice /* duplicate this in another driver
and die */ comment in the right place will do the job just fine IMHO.

-- 
Tomas Szepe <szepe@pinerecords.com>
