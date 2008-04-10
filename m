From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was: Re: [regression]
 e1000e broke e1000)
Date: Thu, 10 Apr 2008 12:27:45 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0804101225570.3143@woody.linux-foundation.org>
References: <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <200804092249.23111.elendil@planet.nl> <m363uqwpds.fsf@maximus.localdomain>
 <alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org> <m34paaav7o.fsf@maximus.localdomain> <alpine.LFD.1.00.0804100724220.3143@woody.linux-foundation.org> <20080410175503.GA11440@colo.lackof.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Frans Pop <elendil@planet.nl>,
	Ingo Molnar <mingo@elte.hu>, jeff@garzik.org, matthew@wil.cx,
	auke-jan.h.kok@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-pci@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, bruce.w.allan@intel.com, greg@kroah.com,
	arjan@linux.intel.com, rjw@sisk.pl
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758454AbYDJT3j@vger.kernel.org>
In-Reply-To: <20080410175503.GA11440@colo.lackof.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 10 Apr 2008, Grant Grundler wrote:
> 
> If e1000e is not getting compiled, my understanding was the original e1000
> driver will claim whatever devices it historically has.

Yes. And the patch to do so was done by yours truly, exactly because I hit 
this thing ;)

But it only works when the e1000e driver isn't enabled at all, which is 
why the "e1000e=m" case ends up being different, and Ingo then hit that 
one.

		Linus
