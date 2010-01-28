From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Which tool to use?
Date: Wed, 27 Jan 2010 23:10:04 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FDD386A6A@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24011 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753744Ab0A1GKH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 01:10:07 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Which tool to use?

Just looking for a bit of direction before I go off and start coding...

Our SR-IOV capable parts (like everybody else's) include simple built-in
Layer 2 switch, to allow packets to be switched between the various VF 
devices.

We need the capability of configuring this switch from userspace. There
are a few features we'd like to control, like anti-spoofing, and
storm control, as well as being able to completely disable the internal
switch for external loopback.  Mostly, however, we want to be able to add
new MAC address filters to the switch.

This is actually a pressing need, for SR-IOV to be really usable in
a virtualized environment. In most use cases, along with VMs that are
assigned VF devices, there will be a bunch of VMs talking through the PF
device via a bridge.  We need to add the MAC addresses of these VMs to
the on-board switch, or other VMs using the VF devices won't be able to
talk to them - the packets will go out on the wire instead.

So, which tool do I modify to make this happen? Ethtool, or ip?  I can
think of convincing arguments for either, so I want to double-check with
the maintainers before I dive in.

Thanks,
Mitch

-------
If we knew what it was we were doing, it would not be called research,
would it?
                                   - Albert Einstein

