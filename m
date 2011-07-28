From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 15:04:22 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D95C@orsmsx508.amr.corp.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
 <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
 <20110727.222749.1654973220321763098.davem@davemloft.net>
 <43F901BD926A4E43B106BF17856F0755019414D509@orsmsx508.amr.corp.intel.com>
 <539DF151-E442-4375-8777-19676B95059B@qlogic.com>
 <43F901BD926A4E43B106BF17856F0755019414D86D@orsmsx508.amr.corp.intel.com>
 <789BE5A3-93DF-4869-A0AF-180AA86F4AC6@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59969 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab1G1WEY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 18:04:24 -0400
In-Reply-To: <789BE5A3-93DF-4869-A0AF-180AA86F4AC6@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Anirban Chakraborty
> Sent: Thursday, July 28, 2011 3:01 PM
> To: Rose, Gregory V
> Cc: David Miller; netdev; Ben Hutchings; Kirsher, Jeffrey T;
> virtualization@lists.linux-foundation.org
> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> 
> 
> On Jul 28, 2011, at 1:38 PM, Rose, Gregory V wrote:
> 
> >
> >> From: Anirban Chakraborty [mailto:anirban.chakraborty@qlogic.com]
> >> Sent: Thursday, July 28, 2011 12:04 PM
> >> To: Rose, Gregory V
> >> Cc: David Miller; netdev; Ben Hutchings; Kirsher, Jeffrey T
> >> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> >>
> >>
> >> If I understood it correctly, you are trying to set/unset spoofing on
> per
> >> eth interface,  which could be a PF on the hypervisor or a pci
> passthru-ed
> >> VF in the linux guest.  There are other security features that one
> could set
> >> for a port on the VF (lets call it vport),  e.g. setting a port VLAN ID
> for
> >> a VF and specifying if the VF (VM) is allowed to send tagged/untagged
> >> packets, setting a vport in port mirroring mode so that the PF can
> monitor
> >> the traffic on a VF,  setting a vport in promiscuous mode etc.
> >>
> >> Does it make sense to try to use ip link util to specify all these
> parameters,
> >> since ip link already does the  job of setting VF properties and VF
> port
> >> profile?
> >>
> >> Any thoughts?
> >>
> >
> > Sure, that's a possibility too.  I was considering ethtool for this
> since MAC addresses and VLANs are fairly specific to Ethernet whereas
> netlink might apply to other types of physical networks.  At least that's
> my understanding.
> 
> You could specify VF MAC and VLANs using netlink today.
> e.g. ip link set ethX vf # mac, vlan etc.
> Adding spoofing as follows would do it.
> ip link set ethX vf # spoof on|off
> 
> Having SR-IOV features scattered among ethtool and ip link may be
> inconvenient for the end users.
> CC-ing virtualization list.
> 
> >
> > However, I have no strong feelings about it and if community consensus
> is to use ip link instead then that's fine by me.
> >
> > Of course, patches implementing such would be quite welcome also.
> 
> I could take a stab at it at the netlink side, if there is a consensus.

Now that I think about it I'm seeing it more your way.  I'll drop the anti-spoofing stuff from my ethtool patches.  If you get the time to provide patches to netlink for anti-spoofing then that's great, otherwise I'll do it when I get done with the SR-IOV reconfig stuff.

Thanks,

- Greg

