From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 20 Jul 2012 09:27:03 -0600
Message-ID: <500978C7.5050004@genband.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>	<5005D45D.1040302@genband.com> <20120717.141153.46613285253481776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ddutile@redhat.com, yuvalmin@broadcom.com,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120717.141153.46613285253481776.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/17/2012 03:11 PM, David Miller wrote:
> From: Chris Friesen<chris.friesen@genband.com>
> Date: Tue, 17 Jul 2012 15:08:45 -0600
>
>>  From that perspective a sysfs-based interface is ideal since it is
>> directly scriptable.
>
> As is anything ethtool or netlink based, since we have 'ethtool'
> and 'ip' for scripting.

I'm not picky...whatever works.

To me the act of creating virtual functions seems generic enough (I'm 
aware of SR-IOV capable storage controllers, I'm sure there is other 
hardware as well) that ethtool/ip don't really seem like the most 
appropriate tools for the job.

I would have thought it would make more sense as a generic PCI 
functionality, in which case I'm not aware of an existing binary tool 
that would be a logical choice to extend.

Chris
