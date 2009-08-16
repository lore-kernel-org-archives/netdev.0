From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Sun, 16 Aug 2009 11:30:49 +0300
Message-ID: <4A87C3B9.2040206@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48212 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbZHPIbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2009 04:31:14 -0400
In-Reply-To: <20090815103243.GA26749@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2009 01:32 PM, Ingo Molnar wrote:
>> This will generally be used for hypervisors to publish any host-side
>> virtual devices up to a guest.  The guest will have the opportunity
>> to consume any devices present on the vbus-proxy as if they were
>> platform devices, similar to existing buses like PCI.
>>
>>      
> Is there a consensus on this with the KVM folks? (i've added the KVM
> list to the Cc:)
>    

My opinion is that this is a duplication of effort and we'd be better 
off if everyone contributed to enhancing virtio, which already has 
widely deployed guest drivers and non-Linux guest support.

It may have merit if it is proven that it is technically superior to 
virtio (and I don't mean some benchmark in some point in time; I mean 
design wise).  So far I haven't seen any indications that it is.

-- 
error compiling committee.c: too many arguments to function

