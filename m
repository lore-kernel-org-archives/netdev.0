From: Quantum Scientific <Info@Quantum-Sci.com>
Subject: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 09:28:44 -0600
Message-ID: <200502270928.44402.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After a week of intensive research and full-time study, it's become clear that 
IPV6 support, as it comes in standard Linux 2.6 kernels, is effectively 
non-functional.

I have a properly working firewall, but it appears there is no stateful 
filtering nor connection  tracking in the IPV6 stack.  I send out an 
echo-request, but have to open icmpv6-129 in order to get the response back.  
Same with http.  We can't open all our incoming ports.  There is no 
IP6_NF_CONNTRACK nor IP6_NF_MATCH_STATE in the kernel.  And if this 
functionality is supposed to be inherent in IPV6, it is not working.

The native IPV6 stack seems to come from oss.sgi.com .  Subscribing to your 
mailing list yields:
List context changed to 'netdev' by following command.
>> appsub netdev Info@Quantum-Sci.com 4221DB53:15AB.1:argqri
Subscribed.
---
Ecartis v1.0.0 - job execution complete.

AH!  But wait... there's no indication of what the list's address is.  Going 
to www.oss.sgi.com gives no indication of where the mailing lists are either.  
So this email is addressed to a guess.

OK, so I subscribed to USAGI.  It was recommended on that list that I install 
the USAGI kernel, but I want to only patch the Debian kernel.  So I DLed 
usagi.snap.split-tool-s20050214.tar.bz2
... however this has no kernel patch within.

So I DLed 
usagi.snap.kit-linux26-s20050214.tar.bz2
... and no kernel patch here either.  Only the kernel and tools.  I would have 
to run a USAGI-specific kernel, in order to have proper IPV6 support.  I must 
stay with the Debian kernel.

I can't believe the native kernel's IPV6 is so primitive.  I can't believe any 
kernel developers are actually using IPV6.  And I can't believe that anyone 
is actually using IPV6 with the Debian kernel.  The Debian IPV6 mailing list 
is full of spam, and brought viruses and scams to my door when I subscribed.  
No one I've asked questions of has mentioned any of this at all, so if there 
is an answer, it is clearly a secret.

So is there something I'm missing?  Am I completely fscked-up when I say that 
it doesn't work in practice, because there is no stateful packet filtering 
nor connection tracking?

Carl Cook
