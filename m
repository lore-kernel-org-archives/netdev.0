From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 23 Jul 2012 10:03:43 -0400
Message-ID: <500D59BF.9040006@redhat.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>			<5005D45D.1040302@genband.com>		 <20120717.141153.46613285253481776.davem@davemloft.net>		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>	 <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com> <5009ECDF.4090305@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, yuvalmin@broadcom.com,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769Ab2GWODz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 10:03:55 -0400
In-Reply-To: <5009ECDF.4090305@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2012 07:42 PM, Chris Friesen wrote:
> On 07/20/2012 02:01 PM, Ben Hutchings wrote:
>> On Fri, 2012-07-20 at 13:29 -0600, Chris Friesen wrote:
>
>>> Once the device exists, then domain-specific APIs would be used to
>>> configure it the same way that they would configure a physical device.
>>
>> To an extent, but not entirely.
>>
>> Currently, the assigned MAC address and (optional) VLAN tag for each
>> networking VF are configured via the PF net device (though this is done
>> though the rtnetlink API rather than ethtool).
>
> I actually have a use-case where the guest needs to be able to modify the MAC addresses of network devices that are actually VFs.
>
> The guest is bonding the network devices together, so the bonding driver in the guest expects to be able to set all the slaves to the same MAC address.
>
> As I read the ixgbe driver, this should be possible as long as the host hasn't explicitly set the MAC address of the VF. Is that correct?
>
> Chris

Interesting tug of war: hypervisors will want to set the macaddrs for security reasons,
                         some guests may want to set macaddr for (valid?) config reasons.
