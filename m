From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 04 Oct 2012 22:21:42 +0930
Message-ID: <87ipaq1jtt.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au> <506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au> <506D3610.7000103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46577 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113Ab2JDMyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 08:54:32 -0400
In-Reply-To: <506D3610.7000103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paolo Bonzini <pbonzini@redhat.com> writes:

> Il 04/10/2012 02:11, Rusty Russell ha scritto:
>> > > There's a reason I haven't done this.  I really, really dislike "my
>> > > implemention isn't broken" feature bits.  We could have an infinite
>> > > number of them, for each bug in each device.
>> >
>> > However, this bug affects (almost) all implementations and (almost) all
>> > devices.  It even makes sense to reserve a transport feature bit for it
>> > instead of a device feature bit.
>>
>> Perhaps, but we have to fix the bugs first!
>
> Yes. :)  Isn't that what mst's patch does?
>
>> As I said, my torture patch broke qemu immediately.  Since noone has
>> leapt onto fixing that, I'll take a look now...
>
> I can look at virtio-scsi.

Actually, you can't, see my reply to Anthony...

Message-ID: <87lifm1y1n.fsf@rustcorp.com.au>

Cheers,
Rusty.
