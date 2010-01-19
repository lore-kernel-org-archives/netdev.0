From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources per
	NUMA node
Date: Tue, 19 Jan 2010 11:34:51 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A692950231698@orsmsx503.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
 <87y6k1dk5t.fsf@basil.nowhere.org>
 <F86E8680A7D9D74A99DC6345E35A6929502312B0@orsmsx503.amr.corp.intel.com>
 <20100119193400.GB24652@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6322 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108Ab0ASTey convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 14:34:54 -0500
In-Reply-To: <20100119193400.GB24652@basil.fritz.box>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andi Kleen [mailto:andi@firstfloor.org]
>Sent: Tuesday, January 19, 2010 11:34 AM
>To: Waskiewicz Jr, Peter P
>Cc: Andi Kleen; Kirsher, Jeffrey T; davem@davemloft.net;
>netdev@vger.kernel.org; gospo@redhat.com
>Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources
>per NUMA node
>
>> >The problem of doing this is that the node might be full or have
>> >no memory and k*alloc_node will fail then.
>> >
>> >So you would need a fallback to be reliable (we probably should have
>a
>> >generic utility function for this somewhere, but we don't currently)
>>
>> So you'd rather see us call kzalloc() if kzalloc_node() fails, instead
>of immediately failing out to err_out?
>
>Yes.
>
>After all it's only an optimization to place memory, it's not
>a functional requirement.
>
>-Andi
>

Makes sense.  I have the change in my local tree and will push new patches through Jeff shortly.

Thanks Andi,
-PJ
