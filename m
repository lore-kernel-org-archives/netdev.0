From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Mon, 28 Feb 2005 01:10:38 +0900 (JST)
Message-ID: <20050228.011038.129063054.yoshfuji@linux-ipv6.org>
References: <200502270928.44402.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: Info@Quantum-Sci.com
In-Reply-To: <200502270928.44402.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200502270928.44402.Info@Quantum-Sci.com> (at Sun, 27 Feb 2005 09:28:44 -0600), Quantum Scientific <Info@Quantum-Sci.com> says:

> After a week of intensive research and full-time study, it's become clear that 
> IPV6 support, as it comes in standard Linux 2.6 kernels, is effectively 
> non-functional.

Sigh...

It is defenetely functional for me.


> usagi.snap.split-tool-s20050214.tar.bz2
> ... however this has no kernel patch within.
> 
> So I DLed 
> usagi.snap.kit-linux26-s20050214.tar.bz2
> ... and no kernel patch here either.  Only the kernel and tools.  I would have 
> to run a USAGI-specific kernel, in order to have proper IPV6 support.  I must 
> stay with the Debian kernel.

I believe you should cry at debian-ipv6 list.

And, you can find usagi kernel patch in split directory, and
you can even find (unsupported) daily kernel snapshot (diff).


> I can't believe the native kernel's IPV6 is so primitive.  I can't believe any 
> kernel developers are actually using IPV6.  And I can't believe that anyone 
> is actually using IPV6 with the Debian kernel.  The Debian IPV6 mailing list 
> is full of spam, and brought viruses and scams to my door when I subscribed.  
> No one I've asked questions of has mentioned any of this at all, so if there 
> is an answer, it is clearly a secret.

Sigh...

Even you can't believe, I actually use IPv6 in my daily life.

I use Debian kernel at first, but in most cases,
I upgrade it to latest usagi tree ASAP.
In this means, I don't usually use Debian IPv6 kernel. (sorry.)


> So is there something I'm missing?  Am I completely fscked-up when I say that 
> it doesn't work in practice, because there is no stateful packet filtering 
> nor connection tracking?

FYI, I hope nf_conntrack, which supports both ipv4 and ipv6, will be 
integrated in 2.6.12 time frame.

Note: nf_conntrack framework is designed and written by Kozakai-san.

--yoshfuji
