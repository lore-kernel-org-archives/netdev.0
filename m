From: jamal <hadi@cyberus.ca>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: 24 Jan 2004 13:00:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074967227.1732.15.camel@jzny.localdomain>
References: <000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-24 at 00:10, Leonid Grossman wrote:

> > - Adaptive Interrupt Coalescence
> 
> There are several interrupt schemes, in the utilization scheme the
> device can be programmed to automatically adjust interrupt rate based
> upon link utilization, independently for tx and rx interrupts. 
> For instance, if the utilization is in single percentage digits then the
> device can be programmed to get an interrupt per every packet since
> interrupt rate doesn't matter much; If the utilization gets closer to
> 100%, it will probably make sense to program device for, say, one
> interrupt per 200 packets - the number will somewhat vary for different
> systems and packet sizes.
> 

How effective is this?
Example you could easily fill up a link with larger packets (less
interupts) than with smaller packets (more interupts). The latter
overloads the system more. 
getting feedback from the system (which you can in Linux) and adjusting
the rate that way would be more effective it seems. Adjusting interupt
rates based on a moving window averaging of the packet arrival rate
would also be useful.

cheers,
jamal
