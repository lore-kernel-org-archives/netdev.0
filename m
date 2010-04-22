From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 17:01:07 -0700
Message-ID: <C7F4DFD3.2A4CC%scofeldm@cisco.com>
References: <20100421221806.GD28829@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Chris Wright <chrisw@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:33688 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab0DVACB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 20:02:01 -0400
In-Reply-To: <20100421221806.GD28829@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/10 3:18 PM, "Chris Wright" <chrisw@redhat.com> wrote:

>> The set_mac_vlan that Scott's patch adds seems to implement 1a), as far
>> as I can tell. Interestingly, this is not actually implemented in
>> the enic driver in patch 2/2. So if we all agree that this is out of the
>> scope of iovnl, let's just remove it from the interface and find another
>> way for it (ethtool, iplink, ..., as listed above).
> 
> Scott, any objection?  At least a way to keep moving forward on the port
> profile bit.

Yes, that's fine with me, port-profile bit is the most important part.
 
>> Note that we still need to pass the MAC address and VLAN ID (or a list
>> of these) to the external switch, my point is just that this should be
>> separate from enforcing it in the hypervisor.
> 
> Yup, we should focus on reconciling the diff of enic vs vpd port profile
> needs.

-scott

