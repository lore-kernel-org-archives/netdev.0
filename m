From: Peter Bieringer <pb@bieringer.de>
Subject: Re: sundance driver does not work with D-Link DFE-580TX
Date: Thu, 19 Jun 2003 14:43:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <57880000.1056026633@worker.muc.bieringer.de>
References: <200305261604.h4QG4iQY020725@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
In-Reply-To: <200305261604.h4QG4iQY020725@sandelman.ottawa.on.ca>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Monday, May 26, 2003 12:04:43 PM -0400 Michael Richardson
<mcr@sandelman.ottawa.on.ca> wrote:

> 
>>>>>> "Peter" == Peter Bieringer <pb@bieringer.de> writes:
>     Peter> pls. take a look into:
> 
>     Peter> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=69000
> 
>     Peter> Looks like current included "sundance.c" driver doesn't work
> proper      Peter> together with current "mii.c" on a D-Link DFE-580TX.
> 
>   This is a redhat bug. Stock kernels do not have this problem.
>   Nor does pure-Becker code.

I (also others independed) finally find the bug:

RHL uses CONFIG_SUNDANCE_MMIO=y on kernel building which causes the
problem. 

Looks like this option should be removed or the driver should be improved
(perhaps autodetection?). Imho it doesn't make much sense to add an compile
option which (in case of enabled) break usages of already available NICs.

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
