From: bert hubert <ahu@ds9a.nl>
Subject: Re: [Question] SMP for Linux
Date: Thu, 17 Oct 2002 12:02:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017100243.GA6569@outpost.ds9a.nl>
References: <20021017112928.B20854@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: niv@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hyochang Nam <cannon@postech.ac.kr>
Content-Disposition: inline
In-Reply-To: <20021017112928.B20854@toad.postech.ac.kr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 17, 2002 at 11:29:28AM +0900, Hyochang Nam wrote:
> Many people helped me to solve the interrupt distribution problem.
> We tested the throughput of Layer 3 forwarding on a SMP machine
> which equips two Zero proessor(2Ghz). This is our results:
>   -------------------------
>        SMP    |  No SMP
>   -------------------------
>     230 Mbps  | 330 Mbps
>   -------------------------

There is something called 'irq affinity' which may be interesting for you.
See here: http://www.dell.com/us/en/esg/topics/power_ps1q02-morse.htm

/proc/irq/?/smp_affinity

> I expected that the SMP might show better throughput than "NO SMP"
> environments. But, contrary to my expectation, SMP showed poor results. 
> I don't know what is my fault in the experiments.

SMP is not always a win.

Regards,

bert hubert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
