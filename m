From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 13:59:35 -0500
Message-ID: <42221897.4000704@pobox.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <422205F7.4080401@tomt.net> <200502271220.06560.Info@quantum-sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Quantum Scientific <Info@quantum-sci.com>
In-Reply-To: <200502271220.06560.Info@quantum-sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quantum Scientific wrote:
> On Sunday 27 February 2005 11:40, Andre Tomt wrote:
> 
>>Connection tracking (as in stateful firewalling) do not a useful ipv6 
>>stack make.. The stack works fine, at least the stack provided in 2.6 
>>kernels.
> 
> ...
> 
>>You seem to be fixed on the idea that a ipv6 stack has to have stateful 
>>firewalling, or else its utter crap, correct? :-)
> 
> 
> No, I'll try to say this clearer.
> 
> The stack works fine in.  And out.  But for a useful virtual circuit you must 
> have something like connection tracking.
> 
> Remember what my issue is:  
> - I have a very tight firewall,
> - I ping6 out,
> - The firewall blocks the reply back, because the connection is stateless!
> - Same with http, etc.
> 
> This means that I have to open for incoming, virtually every port I send 
> outgoing to, or else I do not get any replies. This is what I call 
> non-functional, because one does not open incoming ports, for the most part.
> 
> Why are you not having this problem?

Connection tracking doesn't scale.  It's impossible to hash the entire 
Internet.

	Jeff
