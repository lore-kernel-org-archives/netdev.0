From: bert hubert <ahu@ds9a.nl>
Subject: Re: Suggestions with hard lockup on 4 systems, have oops report
Date: Fri, 16 Jul 2004 21:18:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040716191850.GA5997@outpost.ds9a.nl>
References: <Pine.LNX.4.44.0407161025030.20914-200000@fsg1.nws.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian McEntire <brianm@fsg1.nws.noaa.gov>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407161025030.20914-200000@fsg1.nws.noaa.gov>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 16, 2004 at 11:01:39AM -0400, Brian McEntire wrote:
> Thank you for taking time from your busy days to read this. You all
> (kernel maintainers) rock!  :)

You are running one of the kernels not a lot of people outside of red hat
know the details about. 

> The systems are:
>   Dual Xeon 2.4GHz processors
>   2 GB RAM
>   2 GB swap
>   Ethernet controller: PCI device 14e4:16a7 (BROADCOM Corporation) (rev 2)
>   Dual channel SCSI storage controller: PCI device 1000:0030 (Symbios
>     Logic Inc. (formerly NCR)) (rev 7)

This kind of hardware just asks for 2.6. Furthermore, you'll find that
current kernel hackers will be in a far better position to help you.

>  bcm5700-7.1.22-1

In a recent kernel, you will probably be able to use the tg3 driver instead
of this vendor supplied one, which is generally considered to be inferior or
at least uglier than the in kernel one.


> Code;  f89b669f <[bcm5700]LM_ServiceInterrupts+cf/230>
> 00000000 <_EIP>:
> Code;  f89b669f <[bcm5700]LM_ServiceInterrupts+cf/230>   <=====
>    0:   c7 03 00 00 00 00         movl   $0x0,(%ebx)   <=====

I'm no expert, but this strongly looks like problems in the broadcom driver.

> 133 warnings and 7 errors issued.  Results may not be reliable.

2.6 also has a built-in ksymoops, which gives far more reliable results.

Good luck!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
