From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 04 Oct 2012 09:09:04 +0200
Message-ID: <506D3610.7000103@redhat.com>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au> <506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bogj2j1b.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 04/10/2012 02:11, Rusty Russell ha scritto:
> > > There's a reason I haven't done this.  I really, really dislike "my
> > > implemention isn't broken" feature bits.  We could have an infinite
> > > number of them, for each bug in each device.
> >
> > However, this bug affects (almost) all implementations and (almost) all
> > devices.  It even makes sense to reserve a transport feature bit for it
> > instead of a device feature bit.
>
> Perhaps, but we have to fix the bugs first!

Yes. :)  Isn't that what mst's patch does?

> As I said, my torture patch broke qemu immediately.  Since noone has
> leapt onto fixing that, I'll take a look now...

I can look at virtio-scsi.

Paolo
