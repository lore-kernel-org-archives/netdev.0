From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 13:13:57 +0300
Message-ID: <4A8A7EE5.6090209@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8A7BB9.2020906@redhat.com> <20090818100945.GD13878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54108 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbZHRKOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 06:14:30 -0400
In-Reply-To: <20090818100945.GD13878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2009 01:09 PM, Michael S. Tsirkin wrote:
>
>> mmio and pio don't have this problem since the host can use the address
>> to locate the destination.
>>      
> So userspace could map hypercall to address during setup and tell the
> host kernel?
>    

Suppose a nested guest has two devices.  One a virtual device backed by 
its host (our guest), and one a virtual device backed by us (the real 
host), and assigned by the guest to the nested guest.  If both devices 
use hypercalls, there is no way to distinguish between them.

-- 
error compiling committee.c: too many arguments to function

