From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: High CPU utilization with Bonding driver ?
Date: Mon, 4 Apr 2005 17:49:07 -0700
Message-ID: <004101c53979$45f02800$3a10100a@pc.s2io.com>
References: <Pine.LNX.4.61.0503291027240.23261@linux.site>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>,
        "'Leonid. Grossman \(E-mail\)'" <leonid.grossman@neterion.com>,
        "'Raghavendra. Koushik \(E-mail\)'" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0503291027240.23261@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur,
On what kernel version should your below mentioned patch be applied ? 
We tried on one of the older kernels(2.6.5) and got an Oops while 
loading the bonding driver.

Thanks,
Ravi

-----Original Message-----
From: Arthur Kepner [mailto:akepner@sgi.com]
Sent: Tuesday, March 29, 2005 10:29 AM
To: Ravinandan Arakali
Cc: netdev@oss.sgi.com; bonding-devel@lists.sourceforge.net; Leonid.
Grossman (E-mail); Raghavendra. Koushik (E-mail)
Subject: Re: High CPU utilization with Bonding driver ?



On Tue, 29 Mar 2005, Ravinandan Arakali wrote:

> ....
> Results(8 nttcp/chariot streams):
> ---------------------------------
> 1. Combined throughputs(but no bonding):
> 3.1 + 6.2 = 9.3 Gbps with 58% CPU idle.
> 
> 2. eth0 and eth1 bonded together in LACP mode:
> 8.2 Gbps with 1% CPU idle.
> 
> From the above results, when Bonding driver is used(#2), the CPUs are
> completely maxed out compared to the case when traffic is run
> simultaneously on both the cards(#1).
> Can anybody suggest some reasons for the above behavior ?
> 

Ravi;

Have you tried this patch? 

http://marc.theaimsgroup.com/?l=linux-netdev&m=111091146828779&w=2

If not, it will likely go a long way to solving your 
problem.

--
Arthur
