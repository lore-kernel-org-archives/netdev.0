From: Andre Tomt <andre@tomt.net>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 18:40:07 +0100
Message-ID: <422205F7.4080401@tomt.net>
References: <200502270928.44402.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Quantum Scientific <Info@Quantum-Sci.com>
In-Reply-To: <200502270928.44402.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quantum Scientific wrote:
> After a week of intensive research and full-time study, it's become clear that 
> IPV6 support, as it comes in standard Linux 2.6 kernels, is effectively 
> non-functional.
> 
> I have a properly working firewall, but it appears there is no stateful 
> filtering nor connection  tracking in the IPV6 stack.  I send out an 
> echo-request, but have to open icmpv6-129 in order to get the response back.  
> Same with http.  We can't open all our incoming ports.  There is no 
> IP6_NF_CONNTRACK nor IP6_NF_MATCH_STATE in the kernel.  And if this 
> functionality is supposed to be inherent in IPV6, it is not working.

Connection tracking (as in stateful firewalling) do not a useful ipv6 
stack make.. The stack works fine, at least the stack provided in 2.6 
kernels. The 2.4 stack is severely out of date, however, but should "work".

Connection tracking is on the way, currently a implementation exists in 
the netfilter.org patch-o-matic svn.

<snip>

> I must stay with the Debian kernel.

Debian ships 2.6.8 with ipv6 enabled in Sarge. Not sure about Woody, but 
its ought to be rather outdated by now ;-)

> I can't believe the native kernel's IPV6 is so primitive.  I can't believe any 
> kernel developers are actually using IPV6.  And I can't believe that anyone 
> is actually using IPV6 with the Debian kernel.  The Debian IPV6 mailing list 
> is full of spam, and brought viruses and scams to my door when I subscribed.  
> No one I've asked questions of has mentioned any of this at all, so if there 
> is an answer, it is clearly a secret.

> So is there something I'm missing?  Am I completely fscked-up when I say that 
> it doesn't work in practice, because there is no stateful packet filtering 
> nor connection tracking?

You seem to be fixed on the idea that a ipv6 stack has to have stateful 
firewalling, or else its utter crap, correct? :-)

Not all hosts need firewalling at all, or firewalling is provided by 
routers/firewalls for them. I use ipv6 in production networks, on Linux, 
without special patches.
