From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 13:12:14 -0500
Message-ID: <42220D7E.3000104@pobox.com>
References: <200502270928.44402.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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

Strange how I use this non-functional support every day.


> I have a properly working firewall, but it appears there is no stateful 
> filtering nor connection  tracking in the IPV6 stack.  I send out an 

> So is there something I'm missing?  Am I completely fscked-up when I say that 
> it doesn't work in practice, because there is no stateful packet filtering 
> nor connection tracking?

Yes.  IPv6 does not need NAT'ing.  Everyone should have a global 
address.  Connection tracking is not needed.

	Jeff
