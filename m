From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] Re: Gigabit Kconfig problems with yesterday's update
Date: Sun, 30 May 2004 16:43:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BA4776.5090407@pobox.com>
References: <40B8A37D.1090802@myrealbox.com> <20040530134544.GE13111@fs.tum.de> <20040530143734.GA24627@dth.net> <20040530094120.61b22d2e.rddunlap@osdl.org> <40BA1F25.4080402@pobox.com> <20040530193706.GG13111@fs.tum.de> <Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@fs.tum.de>, linux-kernel@vger.kernel.org,
        "Randy.Dunlap" <rddunlap@osdl.org>, Danny ter Haar <dth@dth.net>,
        wa1ter@myrealbox.com, dth@ncc1701.cistron.net,
        Netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> is it really sane these days to split out gigabit from the "regular" 
> ethernets? gigabit ethernet is getting quite a bit more common than it 
> used to be, and a lot of the gigabit devices are just "standard ethernet" 
> as far as the user is concerned, and in fact they are often _used_ in just 
> regular 10/100Mbps setups.

> In other words: it's quite understandable if somebody doesn't even
> _realize_ that his chip supports gigabit speeds these days.

That's ok.  Most users have no idea that their "Surecom 1234 Zippy 
Ethernet" is really an 8139 chip, and that they need the 8139too driver.

Kernel configuration is for kernel developers, kernel vendors 
(distributions), and power users, all of whom are expected to know what 
they are doing.

So, I disagree with that argument.

However...

> If the menu then grows really big, maybe we can split it according to some 
> _saner_ split. Not that I can see off-hand what that would be, but..

...I won't reject arguments based on general annoyance, or specific 
annoyance at the categorizing.  This change was the way I preferred that 
the network driver Kconfig start moving, with future categorizations as 
well -- the overall goal being that eventually you'll select among 
several classes of devices, instead of today's innumerably long list of 
devices from the first days of ethernet to today's 10Gbps.

The easy fix is just to cset -x the change I commited.  Ethernet and 
"gigabit ethernet" will be in separate menus, but there will not a 
separate CONFIG_NET_GIGE option.  I won't complain, if people feel 
'cset -x' is warranted.  It's just a config option, not anything 
terribly important[1]

	Jeff


[1] Of course, this is lkml, the big arguments are always over 
trivialities like this ;-)
