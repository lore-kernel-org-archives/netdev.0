From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Sudden kernel panic with skge in 3.3-rc2
Date: Fri, 3 Feb 2012 14:28:32 -0500
Message-ID: <20120203192832.GA19248@elliptictech.com>
References: <20120202192115.GA8480@elliptictech.com>
 <20120202124529.3e274223@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120202124529.3e274223@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 2012-02-02 12:45 -0800, Stephen Hemminger wrote:
> On Thu, 2 Feb 2012 14:21:15 -0500
> Nick Bowler <nbowler@elliptictech.com> wrote:
> > I just saw this panic on 3.3-rc2 with skge.  I don't know whether it's
> > reproducible yet -- the machine crashed while I was not actively using
> > it.  We've had this type of card for a few years and I've never seen this
> > before so it may be a regression, but admittedly we don't use them all
> > that often.
[...]
> 
> Try reverting this commit, it seems problematic
> commit d0249e44432aa0ffcf710b64449b8eaa3722547e
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Thu Jan 19 14:37:18 2012 +0000
> 
>     skge: check for PCI dma mapping errors

Thanks for the pointer, I'll try that.  Unfortunately some other stuff
has come up so I probably won't be able to test it until next week.

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
