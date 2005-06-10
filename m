From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 14:33:55 -0700
Message-ID: <42AA0743.1020101@hp.com>
References: <42A8E0FE.3020708@candelatech.com> <1118361376.5838.20.camel@rh4>	<42A8EBDA.6010306@candelatech.com> <1118363861.5838.29.camel@rh4> <42AA016C.9050801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42AA016C.9050801@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Have you done any tests with 2 tg3 NICs in a single machine to see if they
> can run at or near line speed (full duplex)?

It isn't just a question of two tg3 NICs in the same box is it?  You are running 
two NICs on the same bus right?  And unless my dimm memory is mistaken, four 
ports on a card with 5704s means two 5704's a bridge chip right?  So, it would 
be two tg3 NICs going through the same bridge chip, not just the same bus or 
same system.  I'd be worrying about DMA latencies on the system and the bridge 
chip, and perhaps the efficiency of the PCI-X bus usage (not sure - is there 
anything in your system's chipset to extract that sort of information?)

What happens when you turn pktgen around/insideout and source packets from the 
bridging system to each of the (two other?) systems?

Since you are bridging, does having CKO enabled really matter?  Mightn't that 
allow the firmware on the 5704(s) to run a triffle faster?  Or does bridging 
already not request CKO (I suppose it might).

Are your interface interrupts distributed across the CPUs?

rick jones
