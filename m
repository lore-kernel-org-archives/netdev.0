From: akepner@sgi.com
Subject: Re: [Patch 3/3 2.4] e1000: Update Documentation/networking/e1000.txt
Date: Fri, 15 Oct 2004 12:20:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410151153120.31839-100000@localhost.localdomain>
References: <ckp6tr$nrg$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <ckp6tr$nrg$1@sea.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004, Jason Lunz wrote:

> ganesh.venkatesan@intel.com said:
> > +          This sets the InterruptThrottleRate to 3000 interrupts/sec for the 
> > +          first, second, and third instances of the driver. The range of 2000 to 
> > +          3000 interrupts per second works on a majority of systems and is a 
> > +          good starting point, but the optimal value will be platform-specific. 
> > +          If CPU utilization is not a concern, use RX_POLLING (NAPI) and default 
> > +          driver settings.
> 
> I don't understand this bit. Isn't the point of NAPI to disable rx
> interrupts entirely, and only gather as many frames from the driver as
> CPU time permits? That's supposed to limit network-rx CPU usage, not
> increase it as the above paragraph implies.

In my experience (on Altix systems, so that experience may be 
somewhat atypical), NAPI results in few (2-7) packets processed 
per interrupt, so the interrupt rate (and CPU utilization) can be 
very high. Interrupt coalescence is much better in both of these 
respects.

-- 
Arthur
