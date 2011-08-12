From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Aug 12 (benet/be2net)
Date: Fri, 12 Aug 2011 15:14:09 -0700
Message-ID: <20110812151409.b8af0108.rdunlap@xenotime.net>
References: <20110812171311.4d7bb640f38838bf7c34df50@canb.auug.org.au>
	<20110812135618.a209d9af.rdunlap@xenotime.net>
	<20110812150607.2303e10e@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812150607.2303e10e@nehalam.ftrdhcpuser.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Aug 2011 15:06:07 -0700 Stephen Hemminger wrote:

> On Fri, 12 Aug 2011 13:56:18 -0700
> Randy Dunlap <rdunlap@xenotime.net> wrote:
> 
> > On Fri, 12 Aug 2011 17:13:11 +1000 Stephen Rothwell wrote:
> > 
> > > Hi all,
> > > 
> > > [The kernel.org mirroring is being very slow today]
> > 
> >   [s.l.o.w.]
> >  
> > > The net tree gained a build failure do I used the version from
> > > next-20110811.
> > 
> > 
> > On i386:
> > 
> > drivers/built-in.o: In function `be_rx_eqd_update':
> > be_main.c:(.text+0x569229): undefined reference to `__udivdi3'
> > 
> 
> Already fixed:

That's really good news.  It appears to be re-b0rked
or this patch is not in linux-next yet.


> Author: Eric Dumazet <eric.dumazet@gmail.com>  2011-08-08 23:23:07
> Committer: David S. Miller <davem@davemloft.net>  2011-08-12 02:54:22
> Parent: 9aebddd11be42366f89b0296590770c02797aa98 (be2net: Move the Emulex driver)
> Branches: master, remotes/origin/master
> Follows: v3.0
> Precedes: 
> 
>     benet: fix build error on 32bit arch
>     
>     Error comes from commit ac124ff973e27802797
>     (be2net: cleanup and refactor stats code)
>     
>     ERROR: "__udivdi3" [drivers/net/benet/be2net.ko] undefined!
>     
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     CC: Sathya Perla <sathya.perla@emulex.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
