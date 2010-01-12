From: Greg KH <gregkh@suse.de>
Subject: Re: Can we remove pci_find_device() yet?
Date: Tue, 12 Jan 2010 09:39:47 -0800
Message-ID: <20100112173947.GA7784@suse.de>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <4B4CA666.1050505@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754469Ab0ALRji@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B4CA666.1050505@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 12, 2010 at 05:42:14PM +0100, Tilman Schmidt wrote:
> Am 2010-01-11 21:01 schrieb Greg KH:
> > On Mon, Jan 11, 2010 at 08:46:50PM +0100, Tilman Schmidt wrote:
> >>
> >> Just an idea - as a stopgap measure, couldn't pci_find_device() be made
> >> a private function of the HiSax drivers? That way, the remainder of the
> >> kernel won't be polluted by it anymore, and the PCI_LEGACY config option
> >> can be dropped. Something like this quick and dirty hack:
> > 
> > Close, but if you do this, please name the function
> > hisax_find_pci_device() or something, and change the drivers to use it
> 
> Sorry, but no. That would drag me into the checkpatch.pl swamp,
> a place I know well enough by now to avoid it whenever possible.

I don't understand, why?

> Many of the calls to pci_find_device() have checkpatch problems
> which of course do not go away by just substituting another
> function name, so I would be obliged to restructure all those
> call sites by hand for the sake of "not introducing new code
> with checkpatch problems". BTDT.

No you would not, don't be crazy.  Modfying a single line to rename a
function from one thing to another could never be decreed as a "don't
add bad code".  And if someone says it is, well, you just found someone
who doesn't know what they are doing :)

> So I'll drop that idea. If someone else wants to pick it up,
> feel free to do so.

Please continue with this idea, it's sane, and valid.

thanks,

greg k-h
