From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 19:50:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331195020.4fff9171.ak@suse.de>
References: <200403311201.i2VC13D19579@zero.aec.at>
	<Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi>
	<20040331135449.GB62402@colin2.muc.de>
	<Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi>
	<20040331151047.GA6033@colin2.muc.de>
	<406B001A.1030901@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, vnuorval@tcs.hut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <406B001A.1030901@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004 09:30:02 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Andi Kleen wrote:
> > On Wed, Mar 31, 2004 at 05:24:47PM +0300, Ville Nuorvala wrote:
> > 
> >>There just doesn't seem to be any general flag field in sk_buff that we
> >>might use at this moment. Should one be added, or should we just hide the
> >>flag inside the cb field using the likes of inet_skb_parm and
> >>inet6_skb_parm?
> > 
> > 
> > There are no free bits indeed. I think ->cb is the best choice then.
> 
> Why not add a 32-bit field to the skb to handle various flag needs
> going forward?

That is what ->cb already is

-Andi
