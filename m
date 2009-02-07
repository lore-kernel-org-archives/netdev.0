From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_dma: call dmaengine_get only if NET_DMA enabled
Date: Fri, 06 Feb 2009 22:05:31 -0800 (PST)
Message-ID: <20090206.220531.81492830.davem@davemloft.net>
References: <20090206.192910.42610645.davem@davemloft.net>
	<20090206.215533.166740686.davem@davemloft.net>
	<498D241F.4080005@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anemo@mba.ocn.ne.jp, maciej.sosnowski@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755214AbZBGGFs@vger.kernel.org>
In-Reply-To: <498D241F.4080005@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Feb 2009 23:03:11 -0700

> David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Fri, 06 Feb 2009 19:29:10 -0800 (PST)
> > 
> >> From: Dan Williams <dan.j.williams@intel.com>
> >> Date: Fri, 6 Feb 2009 15:52:35 -0700
> >>
> >>> Yes, it has been on the todo list for a while, but I eventually want
> >>> the net case to look more like the raid case.  I.e. have one code path
> >>> that picks async versus sync at runtime, with the option to compile
> >>> out async support with header file ifdefs only.
> >> And how does any of that get us any closer to a fix right now
> >> for this problem that doesn't require an ifdef?
> >>
> >> Someone please work on this.
> > I guess that'd end up being me....
> 
> Not necessarily, you did snap me back into reality with that comment.
> 
> > How about something like this?
> 
> Looks good.

Ok, I'll add this to net-2.6 then, thanks.
