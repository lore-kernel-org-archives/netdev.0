From: "David S. Miller" <davem@davemloft.net>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Fri, 10 Sep 2004 14:14:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910141400.1cdf2e18.davem@davemloft.net>
References: <20040909164834.GB18994@postel.suug.ch>
	<20040909103344.5a448b01.davem@davemloft.net>
	<20040909175411.GB19155@postel.suug.ch>
	<20040910.103341.28767986.yoshfuji@wide.ad.jp>
	<20040910092948.GB19930@postel.suug.ch>
	<20040910024030.28b7c66c@linux.site>
	<1094822205.1125.113.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, tgraf@suug.ch, yoshfuji@wide.ad.jp,
        eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1094822205.1125.113.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 10 Sep 2004 09:16:46 -0400
jamal <hadi@cyberus.ca> wrote:

> 
> On Fri, 2004-09-10 at 05:40, Stephen Hemminger wrote:
> > Unless there is some compelling reason, I think that keeping the old ioctl
> > interface for a least a year until the kernel changes become more ubiquitous.
> 
> I think that iproute2 should first attempt to use netlink and on failure
> switch to ioctls.

This is what I would recommend too.
