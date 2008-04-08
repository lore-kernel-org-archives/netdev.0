From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [regression] e1000e broke e1000 (was: Re: [ANNOUNCE] e1000 toe1000e migration of PCI Express devices)
Date: Tue, 8 Apr 2008 14:04:18 -0600
Message-ID: <20080408200417.GI11962@parisc-linux.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com> <20080408195949.GB28148@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757638AbYDHUEs@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080408195949.GB28148@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 08, 2008 at 09:59:49PM +0200, Ingo Molnar wrote:
> Btw., a sidenote: this is another generally annoying property of Linux: 
> there's no easy and user-visible enumeration of PCI IDs (devices) that 
> we _could_ support but dont enable for some reason. It is a royal PITA 
> to track down when some driver decides to (silently) ignore a piece of 
> hardware.
> 
> Having a seemingly dead piece of hardware component is one of the most 
> frustrating user experiences possible - the first instinctive reaction 
> is "did my hw break???". The kernel should proactively know about all 
> inactive pieces of hardware and should have a one-stop-shop for users 
> where they can reassure themselves which devices are not active and why.

It's almost trivial to add new string attributes to sysfs.  We could
have a file, say, /sys/bus/pci/devices/0000:07:03.0/broken which
lspci could read to see if anything's left a message for us.

Is that the kind of thing you had in mind?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
