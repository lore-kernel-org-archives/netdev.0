From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was: Re: [regression] e1000e broke e1000)
Date: Thu, 10 Apr 2008 12:04:13 -0600
Message-ID: <20080410180412.GV11962@parisc-linux.org>
References: <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <200804092249.23111.elendil@planet.nl> <m363uqwpds.fsf@maximus.localdomain> <alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org> <m34paaav7o.fsf@maximus.localdomain> <alpine.LFD.1.00.0804100724220.3143@woody.linux-foundation.org> <20080410175503.GA11440@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Frans Pop <elendil@planet.nl>, Ingo Molnar <mingo@elte.hu>,
	jeff@garzik.org, auke-jan.h.kok@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	linux-pci@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, bruce.w.allan@intel.com, greg@kroah.com,
	arjan@linux.intel.com, rjw@sisk.pl
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758418AbYDJSEo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080410175503.GA11440@colo.lackof.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 10, 2008 at 11:55:03AM -0600, Grant Grundler wrote:
> Agreed. I like Ingo's Kconfig patch which forces both drivers
> (e1000 and e1000e) to be built the same way (ie both modules or both
> builtin).

Uh, that's /not/ what Ingo's patch does.  His patch makes e1000 claim
the e1000e IDs if e1000 is built-in and e1000e is a module.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
