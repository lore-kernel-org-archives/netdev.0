From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 07 Jun 2005 16:19:46 -0700
Message-ID: <42A62B92.2050701@hp.com>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>	<Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>	<42A5284C.3060808@osdl.org>	<1118147904.6320.108.camel@localhost.localdomain>	<Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>	<1118150948.6320.152.camel@localhost.localdomain>	<Pine.LNX.4.58.0506071432570.16594@tux.rsn.bth.se> <17061.52365.336303.369135@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, jamal <hadi@cyberus.ca>,
        Stephen Hemminger <shemminger@osdl.org>,
        Mitch Williams <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
In-Reply-To: <17061.52365.336303.369135@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
>  BTW, Can netperf be used for tests like this? (Rick?)

Assuming I'm translating "test like this" to the right sort of stuff :)

If one wants to see the effect of different buffer replenishment strategies, I 
suppose that some netperf tests could indeed be used.  It would be desirable to 
look at service demand moreso than throughput (assuming the throughput is 
link-bound).  TCP_STREAM and/or TCP_MAERTS.  I'm not sure the extent to which it 
would be visible to a TCP_RR test.

Differences in service demand could also be used to measure effects of irq 
migration, pinning IRQs and/or processes to specific CPUs and the like.  The 
linux processor affinity stuff in netperf could use a little help though - it is 
easily confused as to when to use a two argument vs three argument 
sched_setaffinity call.  I suspect one may also see differences in TCP_RR 
transaction rates.

I suspect some high number of confidence interval iterations might be required.

rick jones

i'd trim individual names from the dist list, but am not 100% sure who is on 
netdev...
