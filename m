From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Extend lock less TX to real devices
Date: 04 Sep 2004 10:11:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094307106.1634.147.camel@jzny.localdomain>
References: <m38ybvjxdv.fsf@averell.firstfloor.org>
	 <20040901223301.1a8d97a8.davem@redhat.com>  <20040904132809.GB33964@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Alexey <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040904132809.GB33964@muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-04 at 09:28, Andi Kleen wrote:
> On Wed, Sep 01, 2004 at 10:33:01PM -0700, David S. Miller wrote:
> > On Tue, 31 Aug 2004 14:38:20 +0200
> > Andi Kleen <ak@muc.de> wrote:
> > 
> > > This patch extends the recently added NETIF_F_LLTX to real devices.
> > 
> > Well, it does a lot of other things too.
> 
> Not really, it all works to the same goal.

Must be my sleep depravation - what is LLTX again?
 

> > least the user would find out in their logs.  With your
> > change the system explodes looping with no explanation why.
> 
> Hmm, I guess if you're really worried about this class
> of driver bugs ble eing common adding some real error handling
> for it (like bailing out and disabling the device) would
> be the far better option.

Actually that message is pretty useful.
I have seen at least a handful of badly written drivers do that.
Was also very useful for me when i was doing the tc extensions.
I was able to catch a few bugs - so not just driver related.


> > patch 1) Change macros into inlines
> > patch 2) local_bh_disable() preemption count optimization
> > patch 3) support for F_LLTX on real devices
> > patch 4) locking changes
> 
> At least (3) and (4) are the same thing. I can drop the 
> inlines, it was only for making the code clearer and less ugly
> but is not essential for the optimizations.

do you guys mind if i test these patches/patch out first before final 
inclusion? Next weekend i will have the chance.

cheers,
jamal
