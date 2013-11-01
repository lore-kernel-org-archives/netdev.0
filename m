From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 12:08:02 -0400
Message-ID: <20131101160802.GB8467@hmsreliant.think-freely.org>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
 <20131030110214.GA10220@localhost.localdomain>
 <52710B09.6090302@redhat.com>
 <20131031183003.GC25894@hmsreliant.think-freely.org>
 <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 01, 2013 at 03:42:46PM +0000, Ben Hutchings wrote:
> On Thu, 2013-10-31 at 14:30 -0400, Neil Horman wrote:
> [...]
> > It
> > functions, but unfortunately the performance lost to the completely broken
> > branch prediction that this inflicts makes it a non starter:
> [...]
> 
> Conditional branches are no good but conditional moves might be worth a shot.
> 
> Ben.
> 
How would you suggest replacing the jumps in this case?  I agree it would be
faster here, but I'm not sure how I would implement an increment using a single
conditional move.
Neil

> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
