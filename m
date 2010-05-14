From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: SR-IOV PCI quirk for 82599?
Date: Fri, 14 May 2010 09:57:35 -0700
Message-ID: <DDC57477F5D6F845A0DDCB99D3C4812D0CA63BBBE6@orsmsx510.amr.corp.intel.com>
References: <0199E0D51A61344794750DC57738F58E70B078DCA0@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Fischer, Anna" <anna.fischer@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53513 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968Ab0ENQ6B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:58:01 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E70B078DCA0@GVW1118EXC.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is a PCI quirk for the 82576 controller that programs the PCI
> BARs to use Flash memory if the BIOS has not allocated resources for
> the SR-IOV VF BARs.
> 
> Is there a similar quirk for the 82599, or can even the same one be
> used for that device?
> 
> Thanks,
> Anna
The quirk is for system BIOS's that don't fully support SR-IOV.  The quirk is for those systems with these bad BIOS's with our (and others) devices in them.  So we think the same quirk could be used but we have never test with it in a system with a Niantic device in it.  So we don't know if it would work or not.  It should but without testing there is no way to know for sure.

Cheers,
John


