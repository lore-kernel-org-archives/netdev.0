From: Pekka Savola <pekkas@netcore.fi>
Subject: IPSEC and MPLS priority for 2.6?
Date: Thu, 18 Dec 2003 09:36:15 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Andrew characterized (or Dave) did the lack of MPLS support as a huge 
issue for serious IPSEC usage in:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/must-fix/should-fix-7.txt
[see below]

.. I don't agree.  MPLS is only needed for IPsec VPNs in the case that 
Linux is being used as an MPLS router, like as Provider Edge device.  
I think it's safe to say this is close to a marginal application of 
Linux.  I don't think this is Priority 1 ("we're totally lame if we 
don't do it") thing -- at least from the IPsec perspective.  I'd 
suggest pushing it down in the priority list.

But of course, if a rewrite is already almost done, I have no 
objections to merging it.  I'd just like to point out that IMHO MPLS 
is _not_ one of our "core" technologies to worry about :-).

(Btw, there's a lot of claimed IPR on MPLS technologies, not sure if 
that's a problem or not.)

****** snip *******

net/
~~~

  (davem)

o Real serious use of IPSEC is hampered by lack of MPLS support.  MPLS is a
  switching technology that works by switching based upon fixed length labels
  prepended to packets.  Many people use this and IPSEC to implement VPNs
  over public networks, it is also used for things like traffic engineering.

  A good reference site is:

	http://www.mplsrc.com/

  Anyways, an existing (crappy) implementation exists.  I've almost
  completed a rewrite, I should have something in the tree next week.

  PRI1



-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
