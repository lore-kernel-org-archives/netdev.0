From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Fri, 10 Sep 2004 11:29:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910092948.GB19930@postel.suug.ch>
References: <20040909164834.GB18994@postel.suug.ch> <20040909103344.5a448b01.davem@davemloft.net> <20040909175411.GB19155@postel.suug.ch> <20040910.103341.28767986.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, shemminger@osdl.org,
        eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>
Content-Disposition: inline
In-Reply-To: <20040910.103341.28767986.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20040910.103341.28767986.yoshfuji@wide.ad.jp> 2004-09-10 10:33
> > > On Thu, 9 Sep 2004 18:48:34 +0200
> > > Thomas Graf <tgraf@suug.ch> wrote:
> > > 
> > > > - Convert mtu and txqlen to use rtnetlink instead of ioctl.
> > > > - Introduces weight.
> > > > - Updates local copy of rtnetlink.h.

> Well, I think we should maintain old ioctl path for backward compatibility.
> (or ifdefs at least.)

I agree, however I think that the only good solution would be to have
iproute2 negotiate with the kernel at runtime. I therefore suggest to
consider my iproute2 patches as development only and don't include them
in any releases as long as the whole 'new iproute2 with old kernel' issue,
also affecting the new tc-actions, has been resolved.
