From: Andrew de Quincey <adq_dvb@lidskialf.net>
Subject: Re: Forcedeth and vesa
Date: Fri, 4 Jun 2004 15:41:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406041541.29594.adq_dvb@lidskialf.net>
References: <20040604135640.C218BD0B60@rekin6.o2.pl> <40C0863E.9070508@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: smolny@o2.pl, foner+x-forcedeth@media.mit.edu,
        Manfred Spraul <manfred@colorfullife.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
In-Reply-To: <40C0863E.9070508@gmx.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 04 Jun 2004 15:25, Carl-Daniel Hailfinger wrote:
> Hi,
>
> [foner: I included you in the CC because your problem seems similar.]
>
> smolny@o2.pl wrote:
> > Hi,
> > Sorry if you get this post by mistake. I found your address googling
> > for "forcedeth vesa".
>
> Well, you reached the right person.
>
> > When i use forcedeth module, both with 2.4.26 and 2.6.6 kernels, i
> > can't access vesa with mplayer. Just loading the module doesn't
> > cause the problem, only after i configure the net with ifconfig i
> > can't use vesa.
>
> This is interesting. Does the problem persist if you ifdown the interface?
>
> > If i use nvnet NVidia driver with 2.4.26, everything goes fine (no
> > nvnet for 2.6.x kernels).
>
> That is even more interesting. So the bug affects forcedeth, but not
> nvnet. Hmmm. We'll have to review the code again.
>
> > It's an EPOX 8RDA+ motherboard.
>
> Foner: Do you see similarities between your problem and this one?
>
> Janusz, Foner: Are you willing to test forcedeth with a few dozen
> iterations of
> patch, recompile, install, power down, power up and test again?
>
> I would send you patches to binary search the offending code.

This is rather convenient. I have an Epox 8RDA+ as well. What video card are 
you using in that box?

I'll install mplayer and see if I can replicate (I have an ATI 9800 Pro, but I 
can easily stuff a number of nvidia cards in there to check).

If you're using an ATI or Nvidia card, are you using the proprietary or 
opensource drivers?
