From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: Which tool to use?
Date: Thu, 28 Jan 2010 09:59:59 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559D2D5EF6@orsmsx508.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FDD386A6A@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8507 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab0A1SAG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:00:06 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FDD386A6A@rrsmsx501.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Williams, Mitch A
>Sent: Wednesday, January 27, 2010 10:10 PM
>To: netdev@vger.kernel.org; davem@davemloft.net; Stephen Hemminger
>Subject: Which tool to use?
>
>Which tool to use?
>
>Just looking for a bit of direction before I go off and start coding...
>
>Our SR-IOV capable parts (like everybody else's) include simple built-in
>Layer 2 switch, to allow packets to be switched between the various VF
>devices.
>
>We need the capability of configuring this switch from userspace. There
>are a few features we'd like to control, like anti-spoofing, and
>storm control, as well as being able to completely disable the internal
>switch for external loopback.  Mostly, however, we want to be able to
>add
>new MAC address filters to the switch.
>
>This is actually a pressing need, for SR-IOV to be really usable in
>a virtualized environment. In most use cases, along with VMs that are
>assigned VF devices, there will be a bunch of VMs talking through the PF
>device via a bridge.  We need to add the MAC addresses of these VMs to
>the on-board switch, or other VMs using the VF devices won't be able to
>talk to them - the packets will go out on the wire instead.
>
>So, which tool do I modify to make this happen? Ethtool, or ip?  I can
>think of convincing arguments for either, so I want to double-check with
>the maintainers before I dive in.
>
>Thanks,
>Mitch
>

The folks working on the Open vSwitch project are addressing some of these issues also.  You might want to check them out at openvswitch.org, although I have no idea what sort of view the Linux networking community has towards their work.

- Greg


