From: Quantum Scientific <Info@quantum-sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 12:20:06 -0600
Message-ID: <200502271220.06560.Info@quantum-sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <422205F7.4080401@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <422205F7.4080401@tomt.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 27 February 2005 11:40, Andre Tomt wrote:
> Connection tracking (as in stateful firewalling) do not a useful ipv6 
> stack make.. The stack works fine, at least the stack provided in 2.6 
> kernels.
...
> You seem to be fixed on the idea that a ipv6 stack has to have stateful 
> firewalling, or else its utter crap, correct? :-)

No, I'll try to say this clearer.

The stack works fine in.  And out.  But for a useful virtual circuit you must 
have something like connection tracking.

Remember what my issue is:  
- I have a very tight firewall,
- I ping6 out,
- The firewall blocks the reply back, because the connection is stateless!
- Same with http, etc.

This means that I have to open for incoming, virtually every port I send 
outgoing to, or else I do not get any replies. This is what I call 
non-functional, because one does not open incoming ports, for the most part.

Why are you not having this problem?


> Connection tracking is on the way, currently a implementation exists in 
> the netfilter.org patch-o-matic svn.

Is this reasonably solid?  Does this operate on Layer 3, rather than Layer 2?


> Not all hosts need firewalling at all, or firewalling is provided by 
> routers/firewalls for them. I use ipv6 in production networks, on Linux, 
> without special patches.

Sorry, I disagree.  The whole point of IPV6 is ubiquitous addressing.  So 
every single node must have a good firewall.  In fact my router is 
firewalling as well, so my LAN nodes are double-firewalled.

It is irresponsible to not firewall all nodes, as they are supposed to be 
universally available with this paradigm.

Carl Cook
