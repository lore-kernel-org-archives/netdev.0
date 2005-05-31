From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 31 May 2005 18:28:43 -0500
Message-ID: <200505311828.44304.jdmason@us.ibm.com>
References: <1117241786.6251.7.camel@localhost.localdomain> <200505311707.54487.jdmason@us.ibm.com> <20050531.151443.74564699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, hadi@cyberus.ca, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050531.151443.74564699.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 31 May 2005 05:14 pm, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Date: Tue, 31 May 2005 17:07:54 -0500
>
> > Of course some performace analysis would have to be done to determine the
> > optimal numbers for each speed/duplexity setting per driver.
>
> per cpu speed, per memory bus speed, per I/O bus speed, and add in other
> complications such as NUMA
>
> My point is that whatever experimental number you come up with will be
> good for that driver on your systems, not necessarily for others.
>
> Even within a system, whatever number you select will be the wrong
> thing to use if one starts a continuous I/O stream to the SATA
> controller in the next PCI slot, for example.
>
> We keep getting bitten by this, as the Altix perf data continually shows,
> and we need to absolutely stop thinking this way.
>
> The way to go is to make selections based upon observed events and
> mesaurements.

I'm not arguing against a /proc entry to tune dev->weight for those sysadmins 
advanced enough to do that.  I am arguing that we can make the driver smarter 
(at little/no cost)  for "out of the box" users.
