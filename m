From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 20 Jul 2012 17:42:23 -0600
Message-ID: <5009ECDF.4090305@genband.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>			<5005D45D.1040302@genband.com>		 <20120717.141153.46613285253481776.davem@davemloft.net>		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>	 <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Dutile <ddutile@redhat.com>,
	David Miller <davem@davemloft.net>, yuvalmin@broadcom.com,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2012 02:01 PM, Ben Hutchings wrote:
> On Fri, 2012-07-20 at 13:29 -0600, Chris Friesen wrote:

>> Once the device exists, then domain-specific APIs would be used to
>> configure it the same way that they would configure a physical device.
>
> To an extent, but not entirely.
>
> Currently, the assigned MAC address and (optional) VLAN tag for each
> networking VF are configured via the PF net device (though this is done
> though the rtnetlink API rather than ethtool).

I actually have a use-case where the guest needs to be able to modify 
the MAC addresses of network devices that are actually VFs.

The guest is bonding the network devices together, so the bonding driver 
in the guest expects to be able to set all the slaves to the same MAC 
address.

As I read the ixgbe driver, this should be possible as long as the host 
hasn't explicitly set the MAC address of the VF.  Is that correct?

Chris
