From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 14:16:43 -0700
Message-ID: <1118438203.5294.7.camel@rh4>
References: <42A8E0FE.3020708@candelatech.com>
 <1118361376.5838.20.camel@rh4> <42A8EBDA.6010306@candelatech.com>
 <1118363861.5838.29.camel@rh4> <42AA016C.9050801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <42AA016C.9050801@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-10 at 14:09 -0700, Ben Greear wrote:

> I commented out the code and ran the pktgen test again.  It may be a small
> bit better, but not much:  770Mbps in one direction, 750Mbps in the other.
> 

The latest tg3 driver will print out the dma_rwctrl at probe time. Can
you check the value to make sure ONE_DMA is disabled? Bit 14 sets
ONE_DMA.

> Have you done any tests with 2 tg3 NICs in a single machine to see if they
> can run at or near line speed (full duplex)?
> 

Yes, we have years ago but not with the tg3 driver. We set up the 5704
to bridge (or route, I don't remember) one port to the other. It cannot
bridge at line-rate with the ONE_DMA workaround enabled.
