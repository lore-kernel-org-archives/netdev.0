From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: raw ipv6 broken in 2.4.19
Date: 13 Aug 2002 23:29:35 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029274175.1135.129.camel@tux>
References: <200208132006.AAA21878@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208132006.AAA21878@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, 2002-08-13 at 22:06, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > Alexey, when you had checksum problems, did you see invalid checksums in
> > tcpdump?
> 
> No. It is dubiously similar to your case. It is the sibj
> "Linux TCP problem while talking to hostme.bkbits.net" in linux-kernel.
> It is mistique not less than your case. :-)
> 
> > Does anyone else have an idea or suggestion I can try?
> 
> Well, let's look what exactly checksum routines calculate on the steps.
> Maybe, this will give a clue.

Just tell me what you want me to dig out from the checksumming stuff.

> Actually, tulip is really different of another cards, this creature
> generates badly aligned packets. F.e. it is possible a checksumming routine
> folds some bytes beyond end of frame. :-) I have lots of verious tulips here,
> but have never seen such a shit. :-)

hehe, this isn't a clone, it's a quad with "Digital DS21143 Tulip rev
65" chips (from tulip driver) behind a "PCI bridge: Digital Equipment
Corporation DECchip 21152" (from lspci)

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
