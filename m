From: Andrew de Quincey <adq@lidskialf.net>
Subject: Re: wol support in forcedeth v25
Date: Tue, 20 Apr 2004 00:07:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404200007.59345.adq@lidskialf.net>
References: <Pine.GHP.4.44.0404192205070.11806-100000@elektron.its.tudelft.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: a.verweij@student.tudelft.nl
In-Reply-To: <Pine.GHP.4.44.0404192205070.11806-100000@elektron.its.tudelft.nl>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 19 April 2004 21:11, Arjen Verweij wrote:
> Hi,
>
> Is the wol support in forcedeth v25 complete yet? I was trying it with the
> 2.6.5 kernel it came with, tried the new forcedeth driver with a 2.6.3
> kernel (because firewire seems broken in 2.6.5) however, my box will not
> wake up as of yet.

You're right! It _was_ working with patch-forced-0.25, but it ain't in 2.6.5. 
I'll see if I can spot the problem.

> According to the source there is a FIXME with a comment about powering
> down the NIC. Does this mean that support for wol is incomplete for now?
> Mind you, I am just curious, this is in no way meant as criticism.

That would only be for when WOL is NOT used; I think it has to leave the NIC 
powered up for WOL to work... and as you say it ain't implemented yet.

> On another note, Carl-Daniel mentioned that DEV_NEED_TIMERIRQ might be
> removed from future releases. Is this still the case? Feedback would be
> much appreciated, so I can keep my humble audience up to date on what's
> going on at the wol front.
>
> Thank you guys for your excellent work,
>
> Arjen
> http://atlas.et.tudelft.nl/verwei90/nforce2/index.html
