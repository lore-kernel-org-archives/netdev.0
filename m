From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [patch] 2.6.6-rc3 - r8169 rediff
Date: Sat, 15 May 2004 16:07:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFDCE62C5E.567F9BD2-ON87256E95.0071618C-86256E95.00740B1C@us.ibm.com>
References: <20040515015241.A12010@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040515015241.A12010@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>Do you have an SMP system where you could try the patch below on top of 
the
>usual stuff ?

I tested the latest driver (including the Tx Lock Removal patch) on a 4way 
1.2GHz PPC64 system, and it works fine.  I'll leaving it running over the 
weekend to verify that there are no problems, but my 30 minutes worth of 
tests didn't show any problems at all.

FYI, In order to stress the adapter, I ran some quick performance tests (5 
and 10 second runs with netperf3).  I am getting about 200Mbps throughput. 
 I checked the stock 2.6.5 driver, the latest driver (sans Tx Lock Removal 
patch), and the latest driver with Tx Lock Removal patch.  They all get 
roughly the same throughput numbers (with the Tx Lock Removal being 
slightly faster). 

Thanks,
Jon
