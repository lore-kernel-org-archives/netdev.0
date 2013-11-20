From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: loop on reset adapter with ixgbe
Date: Wed, 20 Nov 2013 18:58:52 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866466FD88724@ORSMSX110.amr.corp.intel.com>
References: <20131120182524.GC16953@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Potenza, Leonardo" <leonardo.potenza@intel.com>
To: William Dauchy <william@gandi.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34727 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab3KTS7D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 13:59:03 -0500
In-Reply-To: <20131120182524.GC16953@gandi.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of William Dauchy
> Sent: Wednesday, November 20, 2013 10:25 AM
> To: netdev@vger.kernel.org
> Cc: Keller, Jacob E; Fastabend, John R; Tantilov, Emil S; Potenza, Leonardo
> Subject: loop on reset adapter with ixgbe
> 
> Hi,
> 
> On some machines with a network card named "Intel Corporation 82599EB
> 10-Gigabit SFI/SFP+"
> 
> At boot time, I'm getting an infinite loop showing these messages:
> 
> ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work after link loss ixgbe
> 0000:03:00.0 eth0: Reset adapter ixgbe 0000:03:00.0 eth0: detected SFP+: 3
> 
> ethtool info:
> driver: ixgbe
> version: 3.8.21-k
> firmware-version: 0x00000000
> 
> I'm using the last linux stable branch v3.10.x.
> 
> I need to unplug/plug the network/cable (a twinax cable) several times to
> stabilize the situation and get some network.
> I was wondering if I should consider this as a driver/firmware bug or if I
> should look for a physical issue (I changed the physical cable several times).
> Or do you need some more info to help understand this issue?
> 
> Best regards,
> --
> William

I also just noticed your firmware looks in correct.  What is the DevID for your device?  Likewise do you have another NIC and if so could you check it's firmware-version?

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>
