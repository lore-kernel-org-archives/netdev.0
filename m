From: Arthur Kepner <akepner@sgi.com>
Subject: Re: High CPU utilization with Bonding driver ?
Date: Tue, 29 Mar 2005 10:29:07 -0800 (PST)
Message-ID: <Pine.LNX.4.61.0503291027240.23261@linux.site>
References: <001601c5348c$3f417f50$3a10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net,
        "Leonid. Grossman (E-mail)" <leonid.grossman@neterion.com>,
        "Raghavendra. Koushik (E-mail)" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ravinandan Arakali <ravinandan.arakali@neterion.com>
In-Reply-To: <001601c5348c$3f417f50$3a10100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


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
