From: Quantum Scientific <Info@Quantum-Sci.com>
Subject: Re: (usagi-users 03232) Re: support of IPv6 by NFS
Date: Wed, 2 Mar 2005 07:13:32 -0600
Message-ID: <200503020713.33133.Info@Quantum-Sci.com>
References: <200503020721.j227Ldir012381@m5p.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <200503020721.j227Ldir012381@m5p.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 02 March 2005 1:21, Elliott Mitchell wrote:
> >From: Quantum Scientific <Info@quantum-sci.com>
> > On Tuesday 01 March 2005 19:19, Elliott Mitchell wrote:
> > > Relying on your firewall is a very bad idea. There are plenty of attacks
> > > you end up allowing through. Patches are a far more critical item. If
> > > you are up to date on patches, the firewall isn't important as no 
packets
> > > can harm you. A firewall is a good secondary defense, but not the 
primary
> > > one.
> > 
> > Please be more precise, because I can't imagine what you could be talking 
> > about.  If everything is closed, no packets can pass -- it's that simple.
> > Please detail exactly what could possibly pass an ip6tables firewall with 
a 
> > policy of DROP, and all incoming ports closed, like this:
> >
> > Chain INPUT (policy DROP 0 packets, 0 bytes)
> > pkts  bytes target prot  opt in out source destination
> > 0  0  ACCEPT all  lo * ::/0  ::/0
> > 0  0  LOG all  * * ::/0  ::/0  limit: avg 5/min burst 5 LOG flags 0 level 
6 
> > prefix `***Firewall6 INPUT*** '
> > 0  0  DROP all  * * ::/0  ::/0
> 
> And it is useful having an IPv6 stack on such a machine for?

You're not listening.  You must be a Republican.

The point I've been trying to get across to you is, with connection tracking 
(which the native 6-stack does not have), 
- you can send out; 
- and the response will be allowed back in, even when a is firewall *closed* 
to incoming as I'd illustrated.  

This is what connection tracking is.  You can close incoming entirely.  I just 
don't know how to say it any clearer.  I think 99% of us get it.

It goes without saying that one should not rely entirely on a firewall.  To 
assert that I say this is a canard.  But the *reason* one should not rely 
entirely on a firewall is, in case you accidentally open a hole, not because 
ip6tables is 'weak'!  
- Of course you should not run services you don't need.  
- Of course you should set listen to an inside interface when you can.  
- Of course you should keep software up to date.  

But you must also DROP everything else, or be completely subject to 
compromise.  Layered security and iptables are scientifically proven.  To say 
that properly-implemented ip6tables are not secure, is just argumentative.

Of course, there's the guy who's asking how to subvert packets before they get 
to ip6tables processing...  anybody else wonder why he wants that?  Notice 
there's no real answer?  He really knows what he's doing, and can't get 
through ip6tables.  This will be instructive to most.

 
> Patching is of much greater importance than even the best of firewalls.
...
> A system without a firewall, but secure software is safe. A system with
> a firewall, but insecure software is unsafe.

Although updating is important, the above are nutty ideas.  Your membership in 
the Flat Earth Society(tm) is confirmed.  Your salary will henceforth be paid 
in Confederate dollars, your medical insurance revoked (it's socialist), and 
your retirement invested in the stock market.  Remember: "War is peace.  
Freedom is slavery.  Ignorance is strength."
 {goes to rent Fahrenheit 451 and The Handmaiden's Tale}


> There could be a buffer overflow in the device driver. There could be an
> overflow in code between the driver netfilter code. These two places are
> unlikely as they're constructed carefully, but it could happen. You could
> also have a hole in how your system log handling software which could be
> triggered through the above firewall. Been a while since the last one,
> but such holes have been found before, and that are doesn't tend to get
> as much scrutiny as the kernel.

In order for a buffer overflow to be of use to an attacker, he must be able to 
instigate it, and inject his own code...  when was the last time you've heard 
of a NIC driver sploit?  Who's going to work for weeks on this, when there 
are thousands of machines like yours out there, only filtering SYN.  These 
are not risks for a properly firewalled machine.  I'm getting the idea you 
have this opinion because you had constructed a poor firewall and been 
compromised.  This is why I wish Shorewall would take up the mantle.

Elliott, I've been hoping you are sincere in this discussion, but it now 
appears you are just trolling.  I've had enough of you.

Carl Cook
