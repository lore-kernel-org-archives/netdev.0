From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ixgbe and SRIOV failure in driver?
Date: Fri, 21 May 2010 12:18:18 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755A79C061C@orsmsx508.amr.corp.intel.com>
References: <0199E0D51A61344794750DC57738F58E70B08A2A20@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Fischer, Anna" <anna.fischer@hp.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3272 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758223Ab0EUTSU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 15:18:20 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E70B08A2A20@GVW1118EXC.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Fischer, Anna
>Sent: Friday, May 21, 2010 9:33 AM
>To: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
>Subject: ixgbe and SRIOV failure in driver?
>
>I am running a system with 3 Intel NICs. Two of them are 82598 devices,
>and one is a SRIOV capable 82599.
>
>All devices use the ixgbe driver. What happens (I believe) now is that
>when the driver loads at first, it sees the 82598 first (because of its
>position in the PCI tree) and then it says "Device not IOV capable -
>switching off IOV."
>
>So then it switches into non-IOV mode, and I can never enable SRIOV on
>my 82599, because the driver does not enable it any more for further
>devices.
>
>So to get around this issue, I tried to use pciback.hide to hide the
>82598 devices from the OS. That way I was hoping that the driver would
>switch on SRIOV on my 82599. However, then I got a kernel panic on boot
>(see below).
>
>I am running Xen 4 and the Dom0 kernel is a 2.6.31 kernel.

The ixgbe driver included with the 2.6.31 kernel does not support SR-IOV.
Where did you get the driver that does?  Please run ethtool -i <ethx> and
post the results.

- Greg Rose
Intel Corp.
Lan Access Division

