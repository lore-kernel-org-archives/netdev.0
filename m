From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 31 May 2005 15:14:43 -0700 (PDT)
Message-ID: <20050531.151443.74564699.davem@davemloft.net>
References: <1117241786.6251.7.camel@localhost.localdomain>
	<Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
	<200505311707.54487.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, hadi@cyberus.ca, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200505311707.54487.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Tue, 31 May 2005 17:07:54 -0500

> Of course some performace analysis would have to be done to determine the 
> optimal numbers for each speed/duplexity setting per driver.

per cpu speed, per memory bus speed, per I/O bus speed, and add in other
complications such as NUMA

My point is that whatever experimental number you come up with will be
good for that driver on your systems, not necessarily for others.

Even within a system, whatever number you select will be the wrong
thing to use if one starts a continuous I/O stream to the SATA
controller in the next PCI slot, for example.

We keep getting bitten by this, as the Altix perf data continually shows,
and we need to absolutely stop thinking this way.

The way to go is to make selections based upon observed events and
mesaurements.
