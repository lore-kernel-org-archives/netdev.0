From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: cpts: Fix build error caused by include of plat/clock.h
Date: Fri, 14 Dec 2012 12:09:18 +0100
Message-ID: <20121214110918.GA7982@netboy.at.omicron.at>
References: <20121213213641.GF4989@atomide.com>
 <20121214071300.GA2253@netboy.at.omicron.at>
 <45364223-10C6-430A-9085-9DE1C79030AF@dominion.thruhere.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tony Lindgren <tony@atomide.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: Koen Kooi <koen@dominion.thruhere.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45364223-10C6-430A-9085-9DE1C79030AF@dominion.thruhere.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 14, 2012 at 10:55:56AM +0100, Koen Kooi wrote:
> 
> Op 14 dec. 2012, om 08:13 heeft Richard Cochran <richardcochran@gmail.com> het volgende geschreven:
> 
> > On Thu, Dec 13, 2012 at 01:36:41PM -0800, Tony Lindgren wrote:
> >> Commit 87c0e764 (cpts: introduce time stamping code and a PTP hardware clock)
> >> mistakenly included plat/clock.h that should not be included by drivers
> >> even if it exists.
> > 
> > Hasn't this already been fixed?
> > 
> >  https://patchwork.kernel.org/patch/1810481/
> >  http://www.spinics.net/lists/linux-omap/msg83132.html
> 
> That patch didn't get applied, so it's still broken in Linus' tree :(

In netdev's patchwork, this was marked "Not Applicable." Dave, can you
possibly take this patch? If not, who should I ask next?

Thanks,
Richard
