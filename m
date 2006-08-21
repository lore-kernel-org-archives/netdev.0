From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Hardware access routines
Date: Mon, 21 Aug 2006 13:57:23 +0530
Message-ID: <200608211357.23600.amitkale@linsyssoft.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608180746090.6875@dut39> <20060818081659.7c515bbf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:21906 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1030379AbWHUI1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:27:39 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060818081659.7c515bbf@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can certainly create a table for all error messages. It'll hurt readability 
of code in many of the other places where printks are used to indicate some 
hardware error.
-Amit

On Friday 18 August 2006 20:46, Stephen Hemminger wrote:
> > +	if (fw_major != _NETXEN_NIC_LINUX_MAJOR) {
> > +		printk(KERN_ERR "The mismatch in driver version and firmware "
> > +			"version major number\n"
> > +			"Driver version major number = %d \t"
> > +			"Firmware version major number = %d \n",
> > +			_NETXEN_NIC_LINUX_MAJOR, fw_major);
> > +		adapter->driver_mismatch = 1;
> > +	}
> > +	if (fw_minor != _NETXEN_NIC_LINUX_MINOR) {
> > +		printk(KERN_ERR "The mismatch in driver version and firmware "
> > +			"version minor number\n"
> > +			"Driver version minor number = %d \t"
> > +			"Firmware version minor number = %d \n",
> > +			_NETXEN_NIC_LINUX_MINOR, fw_minor);
> > +		adapter->driver_mismatch = 1;
> > +	}
>
> You might want a table for this?
