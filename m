From: "Douglas Pollock" <pollockd@magma.ca>
Subject: Re: Realtek 8169 Lock-ups
Date: Sun, 11 Jan 2004 11:23:42 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401111623.i0BGNg3O028990@webmail1.magma.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@oss.sgi.com, damouse@ntlworld.com, brad@mainstreetsoftworks.com,
        kinetik@orcon.net.nz
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Jan 11, Francois Romieu <romieu@fr.zoreil.com> wrote:
> M. Pollock's problems look different:
> - they do not depend on the driver used;

I can confirm that I do not see kernel panics, and that the driver (for all intents and 
purposes) seems to work well for a period of time.  


> - they seem timing/smp related (mobile computer + p4 HT).

I ran without SMP support in the kernel for about 1.5 days on my work network, and did 
not see any of the lock-ups described.  However, this evidence is somewhat 
circumstantial, as we don't have a reproducible test case.

It would be nice if someone could point me to a network stress testing tool (something 
that opens multiple simultaneous connections and keeps them at high load).  I'm hoping 
that such a test might provide a reproducible test case.  This way we could confirm or 
rule-out the SMP relationship.



Thanks,
Doug.
