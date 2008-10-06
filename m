From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Tue, 07 Oct 2008 01:02:08 +0200
Message-ID: <48EA98F0.40302@trash.net>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy> <48EA9223.8090700@trash.net> <48EA964A.6060503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56832 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbYJFXCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 19:02:15 -0400
In-Reply-To: <48EA964A.6060503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Patrick McHardy wrote:
>> Agreed. But the question when to do automatic adjustments remains.
> 
> A matter of interpretation of the principle of least surprise right? 
> Which is less surprising - that a VLAN's MTU drops to match that of the 
> physical interface or that some traffic on the VLAN stops when the 
> physical interface's MTU drops?

The traffic actually shouldn't stop since the MTU isn't enforced by
the lower layers and also usually not by the driver. So I feel unable
to make a policy decision when both views don't seem unreasonable.
Especially given the fact that the "more suprising" behaviour so far
has been our default.

> If physical interface MTUs are going to be bouncing around and VLANs get 
> their MTUs changed then perhaps a VLAN needs both a desired and actual 
> MTU setting.  The VLAN's interface would then be the minimum of the 
> desired and actual MTU.  I suppose it isn't too unlike having both an 
> administrative (desired) and operational (actual) interface state.

Thats assuming that the VLAN device is actually restricted by the
ethernet device settings. I don't know if its always not the case,
but I'm pretty sure it usually isn't. Which means there's no real
need for an operational state wrt. MTUs.
