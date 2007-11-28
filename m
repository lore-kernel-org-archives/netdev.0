From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 28 Nov 2007 18:31:27 +0100
Message-ID: <200711281831.27379.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071127230645.GB31491@one.firstfloor.org> <20071128164817.GK3406@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jon Masters <jonathan@jonmasters.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762018AbXK1Rcc@vger.kernel.org>
In-Reply-To: <20071128164817.GK3406@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 November 2007 17:48:17 Adrian Bunk wrote:
> On Wed, Nov 28, 2007 at 12:06:45AM +0100, Andi Kleen wrote:
> > On Tue, Nov 27, 2007 at 03:00:22PM -0800, Stephen Hemminger wrote:
> >...
> > > of a modular ipv6 is flawed. 
> > 
> > Modules that cannot be unloaded are still useful. Standard case: Distributions
> > like to offer an option to not use ipv6 because that is popular workaround
> > for the common "DNS server eats AAAA queries and causes delays" issue.
> > Forcing the user to rebuild the kernel for this wouldn't be practical.
> > If ipv6 wasn't modular that would be hard to do.
> 
> It should be trivial doing it similar to the selinux=0 boot option.

They safe also a few hundred KB of memory this way.
I know it is not en vogue anymore to care about memory bloat, but
I personally like that.

-Andi 
