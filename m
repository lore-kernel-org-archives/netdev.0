From: Jason Lunz <lunz@falooley.org>
Subject: Re: [Patch 3/3 2.4] e1000: Update Documentation/networking/e1000.txt
Date: Fri, 15 Oct 2004 19:03:23 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ckp6tr$nrg$1@sea.gmane.org>
References: <Pine.LNX.4.44.0410150507590.31227-100000@isotope.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ganesh.venkatesan@intel.com said:
> +          This sets the InterruptThrottleRate to 3000 interrupts/sec for the 
> +          first, second, and third instances of the driver. The range of 2000 to 
> +          3000 interrupts per second works on a majority of systems and is a 
> +          good starting point, but the optimal value will be platform-specific. 
> +          If CPU utilization is not a concern, use RX_POLLING (NAPI) and default 
> +          driver settings.

I don't understand this bit. Isn't the point of NAPI to disable rx
interrupts entirely, and only gather as many frames from the driver as
CPU time permits? That's supposed to limit network-rx CPU usage, not
increase it as the above paragraph implies.

Jason
