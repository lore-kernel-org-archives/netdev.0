From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 16:30:01 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811071548060.23792@wrl-59.cs.helsinki.fi>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
 <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
 <20081105.151015.206163697.davem@davemloft.net>
 <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
 <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811071039480.23629@wrl-59.cs.helsinki.fi>
 <alpine.DEB.1.10.0811071230310.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811071341430.23792@wrl-59.cs.helsinki.fi>
 <6278d2220811070543p51ca2139t13aba28e6dba5ff4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Mikael Abrahamsson <swmike@swm.pp.se>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <6278d2220811070543p51ca2139t13aba28e6dba5ff4@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Nov 2008, Daniel J Blueman wrote:

> then we
> avoid hurting these users by enabling ECN per default when eg
> CONFIG_IP_ADVANCED_ROUTER is set (to little direct benefit of course).

I suppose all distros enable that anyway in generic kernels so it's not 
going to be any different from just enabling it.

> It's a start and a constructive idea; by doing this and documenting
> it, we provide a wake-up call for vendors, laying the path for
> enabling it for all types of host in a few years. Even enabling ECN
> for -rc kernels will raise awareness.
>
> Alternatively, an ECN-day could be publicised targeting the linux tech
> community, where we can report failing networks/sites to a central
> website to quantify actual potential negative impact.

This will still miss much. Eg., the ordering problems were not discovered 
afaik until 2.6.27 release, that's quite long time of testing without 
anybody noticing that hey it's broken (it might be that some distro 
circles saw this with some -rcx if they were using them but that didn't 
gain much attention until 2.6.27 was already out). And at that time 
the imminent release of Ubuntu's made the amount of testers much more 
abundant resource than with some other kernel version.

Agreed that we definately should do more than just turn it on and wait for 
troubles but educating users might turn out to be quite hard problem. 
And certainly there will be troubles as even with the most comprehensive 
attempts within linux' dev+tester community are going to leave major holes 
like was proven with the tcp option ordering saga.


-- 
 i.
