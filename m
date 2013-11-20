From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: loop on reset adapter with ixgbe
Date: Wed, 20 Nov 2013 18:53:14 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866466FD88708@ORSMSX110.amr.corp.intel.com>
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
Received: from mga01.intel.com ([192.55.52.88]:40248 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754678Ab3KTSxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 13:53:30 -0500
In-Reply-To: <20131120182524.GC16953@gandi.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey William,

Thanks for letting know what you're running into, however I don't remember ever seeing a failure quite like this.  I'm wondering if it is something we might have fixed in later versions of the driver.  By any chance could you see if you get the same failure with the latest source forge driver?  It will make it easier to track down if we are looking for something we already fix or a new problem altogether.

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>

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
