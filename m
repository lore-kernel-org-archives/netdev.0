From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: 10 Sep 2004 09:16:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094822205.1125.113.camel@jzny.localdomain>
References: <20040909164834.GB18994@postel.suug.ch>
	 <20040909103344.5a448b01.davem@davemloft.net>
	 <20040909175411.GB19155@postel.suug.ch>
	 <20040910.103341.28767986.yoshfuji@wide.ad.jp>
	 <20040910092948.GB19930@postel.suug.ch>
	 <20040910024030.28b7c66c@linux.site>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        YOSHIFUJI "Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>,
        davem@davemloft.net, eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040910024030.28b7c66c@linux.site>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 2004-09-10 at 05:40, Stephen Hemminger wrote:
> Unless there is some compelling reason, I think that keeping the old ioctl
> interface for a least a year until the kernel changes become more ubiquitous.

I think that iproute2 should first attempt to use netlink and on failure
switch to ioctls.
Maybe Thomas can create such a patch.

cheers,
jamal
