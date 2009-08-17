From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 08:54:26 -0500
Message-ID: <4A896112.9030407@codemonkey.ws>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <20090816071607.GB29537@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:41023 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbZHQNy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 09:54:27 -0400
In-Reply-To: <20090816071607.GB29537@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
>> I think the reason vbus gets better performance for networking 
>> today is that vbus' backends are in the kernel while virtio's 
>> backends are currently in userspace.  Since Michael has a 
>> functioning in-kernel backend for virtio-net now, I suspect we're 
>> weeks (maybe days) away from performance results.  My expectation 
>> is that vhost + virtio-net will be as good as venet + vbus.  If 
>> that's the case, then I don't see any reason to adopt vbus unless 
>> Greg things there are other compelling features over virtio.
>>     
>
> Keeping virtio's backend in user-space was rather stupid IMHO. 
>   

I don't think it's quite so clear.

There's nothing about vhost_net that would prevent a userspace 
application from using it as a higher performance replacement for tun/tap.

The fact that we can avoid userspace for most of the fast paths is nice 
but that's really an issue of vhost_net vs. tun/tap.

 From the kernel's perspective, a KVM guest is just a userspace 
process.  Having new userspace interfaces that are only useful to KVM 
guests would be a bad thing.

Regards,

Anthony Liguori
