From: Peter Lieven <pl@dlhnet.de>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Thu, 16 May 2013 10:47:02 +0200
Message-ID: <51949D06.1060109@dlhnet.de>
References: <50FE5607.9020405@dlhnet.de> <20130123100312.GA8108@redhat.com> <5119E9DC.3000505@dlhnet.de> <1368541284.15129.317.camel@eboracum.office.bytemark.co.uk> <519249F6.3000900@dlhnet.de> <1368542949.15129.354.camel@eboracum.office.bytemark.co.uk> <1368615603.15129.1471.camel@eboracum.office.bytemark.co.uk> <20130516062405.GA26548@redhat.com> <20130516062743.GB26548@redhat.com> <1368692455.15129.1475.camel@eboracum.office.bytemark.co.uk> <20130516084021.GA28125@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nicholas Thomas <nick@bytemark.co.uk>,
	Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ssl.dlhnet.de ([91.198.192.8]:43274 "EHLO ssl.dlh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788Ab3EPIrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 04:47:05 -0400
In-Reply-To: <20130516084021.GA28125@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.05.2013 10:40, schrieb Michael S. Tsirkin:
> On Thu, May 16, 2013 at 09:20:55AM +0100, Nicholas Thomas wrote:
>> Hi,
>>
>> On Thu, 2013-05-16 at 09:27 +0300, Michael S. Tsirkin wrote:
>>> On Thu, May 16, 2013 at 09:24:05AM +0300, Michael S. Tsirkin wrote:
>>>> Is this with or without vhost-net in host?
>>>
>>> never mind, I see it's without.
>>> Try to enable vhost-net (you'll have to switch to -netdev syntax
>>> for that to work) and see if this help.
>>> If it does it's likely a qemu bug if not probably a guest bug.
>>
>> Switching to -netdev is non-trivial for me, unfortunately.
> 
> Interesting. Why is that?
> 
>> Anyway, it's
>> definitely a qemu bug - it happens on kernels 3.2 and 3.9 with 1.4.1,
>> but doesn't happen with qemu 0.15.0 or 1.5.0rc1.
>>
>> I'll have a dig through git to see if I can identify the patch that
>> resolves it. It feels-like qemu sometimes stops reading from the tap
>> file descriptor between ipxe exiting and the linux kernel bringing up
>> the network interface, and never recovers from that.
>>
>> /Nick
> 
> You can try to bisect, yes.
> 

It would be good to bisect this. I would appreciate it. I have a similar problem with rtl8139 (without vhost-net), but I was unable
to reproduce yet.

Thanks,
Peter
