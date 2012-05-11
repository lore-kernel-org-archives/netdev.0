From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for May 10 (net/phy)
Date: Thu, 10 May 2012 22:43:52 -0400 (EDT)
Message-ID: <20120510.224352.2149006669429730060.davem@davemloft.net>
References: <20120510192635.c6f3a55196bbf65f13956e44@canb.auug.org.au>
	<4FAC35E2.4060900@xenotime.net>
	<CAP=VYLon7XRoh9s==wGYjUPNAYaTk8QQx7FGRnaDR97v+O-zXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	david.daney@cavium.com
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLon7XRoh9s==wGYjUPNAYaTk8QQx7FGRnaDR97v+O-zXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 10 May 2012 22:36:55 -0400

> On Thu, May 10, 2012 at 5:40 PM, Randy Dunlap <rdunlap@xenotime.net> wrote:
>> On 05/10/2012 02:26 AM, Stephen Rothwell wrote:
>>
>>> Hi all,
>>>
>>> Changes since 20120508:
>>
>>
>>
>> ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!
> 
> Not just randconfig, but also powerpc allmodconfig:
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/6291463/
> 
> Adding ppc ML to cc.

Adding the guilty party to the CC:.  This really stinks, especially
after I did give the patch submitter a hard time about getting the
dependencies right. :-/
