From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 09:01:49 -0500
Message-ID: <1108994508.1090.155.camel@jzny.localdomain>
References: <4216B62D.6000502@pobox.com>
	 <20050219041007.GA17896@xi.wantstofly.org>
	 <20050219114624.373af63f.davem@davemloft.net> <m1psywb8i4.fsf@muc.de>
	 <20050220164607.GA27891@gate.ebshome.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, "David S. Miller" <davem@davemloft.net>,
        jgarzik@pobox.com, netdev@oss.sgi.com
To: Eugene Surovegin <ebs@ebshome.net>
In-Reply-To: <20050220164607.GA27891@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-02-20 at 11:46, Eugene Surovegin wrote:
> On Sat, Feb 19, 2005 at 09:27:31PM +0100, Andi Kleen wrote:
> > <speculating freely>
> > 
> > It would be nice if the NIC could asynchronously trigger prefetches in
> > the CPU. Currently a lot of the packet processing cost goes
> > to waiting for read cache misses.
> 
> Just FYI :), Freescale 85xx TSECs can prefetch buffers into L2 cache. 
> IIRC they call it buffer "stashing" and gianfar driver has a config 
> option to enable such behavior.
> 
> But in embedded world you usually don't see flashy PR releases for 
> such features :).

yes ;-> Big bad Intel is now going to do this, the rest of the world
better listen.
I have a modified sb1250 driver that i converted to NAPI that does this
(in kernel driver doesnt do either NAPI or stash packets into cache).
Reminds me i have to find that driver and submit. 
In any case, the problem could be x86; about every MIPS board i have
seen (I heard PMC-sierra as well) can do this. To be fair to Big Bad
Intel, they may have made a PR or two ;->

cheers,
jamal
