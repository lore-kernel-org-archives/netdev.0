From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V5 PATCH 0/3] Add port-profile netlink support
Date: Thu, 06 May 2010 09:19:11 -0700
Message-ID: <C8083A0F.2EC10%scofeldm@cisco.com>
References: <201005061551.35254.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:54700 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab0EFQTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:19:13 -0400
In-Reply-To: <201005061551.35254.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/10 6:51 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Thursday 06 May 2010, Scott Feldman wrote:
>> The intent of this patch set is to cover both definitions of port-profile
>> as defined by Cisco's enic use and as defined by VSI discover protocol (VDP),
>> used in VEPA implemenations.  While both definitions are based on pre-
>> standards, the concept of a port-profile to be applied to an external switch
>> port on behalf of a virtual machine interface is common, as well as many
>> of the fields defining the protocols.
> 
> The description no either no longer matches the patches, or you did not make
> the
> changes that were needed based on our last discussion.
> 
> What happened to the base-device argument that you were planning to pass?

Using the IFLA_VF_* model works better for us where the recipient of the
netlink msg is the PF but the msg is to be applied to the VF.  The third
patch illustrates how this fits nicely with SR-IOV devices.  The PF is the
base device.
 
> The fields that I mentioned are needed for VDP
> (associate/pre-associate/disassociate-flag,
> VLAN ID, etc) are not there. I assume that means we should use a different
> data structure for VDP, but then your description above should be updated
> to state that this is no longer common for the two.
> 
> I'll follow up with a draft for VDP based on your definitions.

I tried to accommodate space for VDP, but was hoping you could add the
definitions on top of what I had since your more familiar with VDP and can
do the testing.

Also, I wasn't sure if you could use the existing IFLA_VF_VLAN msg to apply
the VLAN ID or if you wanted VLAN ID also added to IFLA_VF_PORT_PROFILE.

-scott

