From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Use firmware provided index to register a network
 interface
Date: Wed, 22 Sep 2010 12:22:28 -0700
Message-ID: <20100922192228.GB29899@kroah.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100922183137.GA7607@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 01:31:38PM -0500, Narendra K wrote:
> Hello,
> 
> Here is another approach to address the issue of "eth0 does not always
> map to the Integrated NIC Port 1 as denoted on server chassis label".
> For more details please refer to the thread -
> http://marc.info/?l=linux-netdev&m=128163454631618&w=3.
> 
> Patch makes use of the firmware provided index to derive ethN names.
> That way the naming scheme adheres to the existing requirements of
> ethN namespace and with IFNAMSIZ length.

Ick, again, what's wrong with using udev for this as it is designed to?
That way no kernel changes are needed, and no one has to rely on the
BIOS getting the firmware number right (meaning it will work on all
types of systems.)

thanks,

greg k-h
