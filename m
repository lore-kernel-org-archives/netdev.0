From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Fri, 10 Sep 2004 10:33:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910.103341.28767986.yoshfuji@wide.ad.jp>
References: <20040909164834.GB18994@postel.suug.ch>
	<20040909103344.5a448b01.davem@davemloft.net>
	<20040909175411.GB19155@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hadi@cyberus.ca, shemminger@osdl.org,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, yoshfuji@wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20040909175411.GB19155@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040909175411.GB19155@postel.suug.ch> (at Thu, 9 Sep 2004 19:54:11 +0200), Thomas Graf <tgraf@suug.ch> says:

> * David S. Miller <20040909103344.5a448b01.davem@davemloft.net> 2004-09-09 10:33
> > On Thu, 9 Sep 2004 18:48:34 +0200
> > Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > > - Convert mtu and txqlen to use rtnetlink instead of ioctl.
> > > - Introduces weight.
> > > - Updates local copy of rtnetlink.h.
> > > 
> > > Against iproute2-2.6.9-jamal, tested and working.
> > > Will look into remaining ioctls later.
> > 
> > Please don't blindly update rtnetlink.h in iproute2 with
> > the current kernel copy.  The "__KERNEL__" ifdef area
> > is omitted on purpose, yet you added it back in.
> 
> Sorry, included old patch, this is a correct one:

Well, I think we should maintain old ioctl path for backward compatibility.
(or ifdefs at least.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
