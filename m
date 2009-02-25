From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next PATCH 1/2] ixgbe: Move ring features into an enum,
 allowing easier future maintenance
Date: Tue, 24 Feb 2009 17:26:26 -0800
Message-ID: <382A478CAD40FA4FB46605CF81FE39F41F1731EE@orsmsx507.amr.corp.intel.com>
References: <A78C6259B11833419567082E2DC0C256C3A9A322@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16089 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027AbZBYB0a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:26:30 -0500
In-Reply-To: <A78C6259B11833419567082E2DC0C256C3A9A322@orsmsx508.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Tuesday, February 24, 2009 4:37 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Waskiewicz Jr, Peter P
>Subject: Re: [net-next PATCH 1/2] ixgbe: Move ring features 
>into an enum, allowing easier future maintenance
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Tue, 24 Feb 2009 15:40:37 -0800
>
>> From: Shannon Nelson <shannon.nelson@intel.com>
>> 
>> The ring_feature member of ixgbe_adapter is statically 
>allocated based on
>> the supported features of the device.  When a new feature is 
>added, we need
>> to manually update the static allocation.  This patch makes 
>the feature
>> list an enum, eliminating the need for multiple updates to 
>the code when
>> adding a new feature.
>> 
>> Signed-off-by: Peter P Waskiewicz Jr 
><peter.p.waskiewicz.jr@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>Applied.
>
>I would appreciate it if, in the future, Shannon would signoff his
>patches :-)
>

Perhaps a little after the fact, but does this help?  I didn't expect to get credit - they haven't given me credit for my other little tweaks.  Usually I get to remain anonymous...

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>

