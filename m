From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 18 Apr 2005 08:14:55 -0400
Message-ID: <1113826496.7419.78.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse,

I doubt your problem has to do with interrupt rates.
If you say the CPU is "fast" - then the problem is elsewhere.
A fast machine that cant handle 77K interupt/sec would be a pathetic
one.
It could be the PCI IO rate which such a fast system shouldnt have
issues handling.
 
You say it can process upto two packets/interupt -so thats
pretty fast. Actually it could be the e100 issue - try replacing the NIC
with e1000 and repeat your tests and see if you observe the same
issues. 
If you are doing the netperf tests then collect netstat -s output;
/proc/net/softnet_stat is another useful stat to look at.

cheers,
jamal 

On Sun, 2005-17-04 at 23:11 -0700, Brandeburg, Jesse wrote:
> _Summary_
> As the part owner of the e100 driver, this issue has been nagging at me
> for a while.  NAPI seems to be able to swamp a system with interrupts
> and context switches.   In this case the system does not respond to
> having zero cpu cycles available by polling more, as I figured it would.
> This was mostly based on observation, but I included some quick data
> gathering for this mail.
> 
