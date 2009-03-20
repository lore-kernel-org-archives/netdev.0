From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] pci: fix kexec with power state D3
Date: Fri, 20 Mar 2009 12:29:16 +0100
Message-ID: <200903201229.18962.rjw@sisk.pl>
References: <49B1F934.5050006@kernel.org> <20090308110835.GB27811@elte.hu> <20090319184948.44bf5e9a@hobbes.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759926AbZCTL3l@vger.kernel.org>
In-Reply-To: <20090319184948.44bf5e9a@hobbes.lan>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 March 2009, Jesse Barnes wrote:
> > > And, quite frankly, I'm not sure if users will be happy with 
> > > the $subject patch, because it _really_ breaks things (well, 
> > > the kexec users who don't use suspend might be, but surely 
> > > suspend users who don't use kexec won't).
> > 
> > Please note that i havent reviewed the patches and i did not 
> > take any sides in the discussion - i just flagged the maintainer 
> > ping-pong. As long as we pick one of the patches (or a third 
> > one) within a bound amount of time we should be fine :)
> 
> I'll defer to Rafael here; he's been working the most in this area.
> The changelog wasn't very complete for the original patch, but it
> sounds like in the kexec case the newly booted kernel will get an igb
> device in D3 which it can't handle?  That really does sound like a
> driver bug, not something we should mess with in the core.

I have already posted an alternative patch for igb that's been reported to
fix the problem.

Thanks,
Rafael
