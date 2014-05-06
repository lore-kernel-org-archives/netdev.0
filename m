From: Tom Zanussi <tom.zanussi@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Mon, 05 May 2014 23:39:08 -0500
Message-ID: <1399351148.8767.84.camel@empanada>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	 <20140505.231229.136734008603421707.davem@davemloft.net>
	 <20140506032114.GP2382@two.firstfloor.org>
	 <20140505.232327.578134514220748085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140505.232327.578134514220748085.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-05-05 at 23:23 -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 6 May 2014 05:21:14 +0200
> 
> > What parts would you remove to get the foot print down for a 2MB
> > single purpose machine?
> 
> I wouldn't use Linux, end of story.
> 
> Maybe two decades ago, but not now, those days are over.

These 'new' systems we're talking about pretty much are the same as
systems from 20 years ago e.g. Quark, which is essentially a 486, with
tiny amounts of RAM, say less than 2 MB, so I hope those days aren't
over forever for Linux...

Anyway, Andi's net-diet and LTO patches allowed me to go from a kernel
text size of above 1100k down to about 750k with the kernel network
stack running an unmodified small web server (nostromo) and the ability
to drop in a dedicated single-purpose application that this type of
system would typically run e.g. something based on for example UDP.

I was able to get that down to about 620k removing INET completely and
replacing it with LWIP, but LWIP either bloated the application back up
to similar memory usage numbers as with INET configured in, or
alternatively required extensive changes to the application in order to
use the not-bloating low-level interface.

But why go to all that trouble when there's a perfectly good networking
stack in the kernel?  Even if most of these options aren't things that
would be useful to most systems, being able to turn them off and save
1/3 of the kernel text size for tiny systems like this does makes a big
difference...

Tom
