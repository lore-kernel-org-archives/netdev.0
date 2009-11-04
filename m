From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: REGRESSION: On 2.6.32-rc5 the firmware hangs, and the nic is
 unusable.
Date: Wed, 4 Nov 2009 11:15:18 -0800
Message-ID: <4AF1D2C6.20002@qlogic.com>
References: <m1tyxaagal.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:57201 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757909AbZKDTQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 14:16:20 -0500
In-Reply-To: <m1tyxaagal.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric W. Biederman wrote:
> On 2.6.31.5 I get:
> ethtool -i eth0
> driver: netxen_nic
> version: 4.0.30
> firmware-version: 4.0.305
> bus-info: 0000:06:00.0
> 

Agree, 2.6.31 window missed bonding (mac addr setup) fixes.

> And everything works except bonding.
> 
> On 2.6.32-rc5 I dhcp I get an IP
> there is a sanity test ping.

> 
> Then the driver reports a firmware hang and
> the interface goes down and I am dead in the water.
> 

> I'm a bit frustrated with this as it seems with each kernel release
> the driver gets a little bit less usable.
> 
> Have I given you enough information to track this down?

This can be fixed in next rc patch of 2.6.32, if I get enough info to debug.

Could you provide full dmesg, so that I can see what's going on around 
firmware hang message? Also provide your test details (bonding / 
whatever configured).

Thanks,
-Dhananjay
