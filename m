From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Fwd: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Thu, 23 Jan 2014 16:23:57 +0200
Message-ID: <20140123142357.GC21572@redhat.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
 <52D75EA5.1050000@redhat.com>
 <CAEH94Lg7ygXgHqE8ubE+nuunicDqgmnCfO2AuDSS2nXgv5GikQ@mail.gmail.com>
 <20140116085253.GA32073@stefanha-thinkpad.redhat.com>
 <CA+mtBx9PBtYurdnhCKL0MLL8i+_+3yPNWFVj5h6SPJH+YDBCjw@mail.gmail.com>
 <CAEH94LiqVpXUp3myHvTPVHaqrDpK2V6ii+w8Gip61PA+QF2apw@mail.gmail.com>
 <CA+mtBx-Xv6xp3VCq=PKMyboAmDjUWzVrbUhr4WdKQRi1PCansg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932104AbaAWOTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 09:19:22 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx-Xv6xp3VCq=PKMyboAmDjUWzVrbUhr4WdKQRi1PCansg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 10:00:37AM -0800, Tom Herbert wrote:
> >> 1. The aRFS interface for the guest to specify which virtual queue to
> >> receive a packet on is fairly straight forward.
> >> 2. To hook into RFS, we need to match the virtual queue to the real
> >> CPU it will processed on, and then program the RFS table for that flow
> >> and CPU.
> >> 3. NIC aRFS keys off the RFS tables so it can program the HW with the
> >> correct queue for the CPU.
> > Does anyone have time to make one conclusion for this discussion? in
> > particular, how will rx packet be steered up the stack from guest
> > virtio_net driver, virtio_net NIC, vhost_net, tun driver, host network
> > stack, to physical NIC with more details?
> > What is the role of each path units? otherwise this discussion wont
> > get any meanful result, which is not what we expect.
> >
> Working code outweighs theoretical discussion :-).

So far all that was posted was an untested patchset.
Zhi Yong Wu did this intentionally to get early feedback, so
it's not surprising we got a theoretical discussion
as opposed to working code out of this.

> I think you started
> on a good track with original patches, and I believe the tun path
> should work pretty well (some performance numbers would still be good
> to validate).

Yes, merging performance-oriented patches without any
performance numbers to show for it is strange.

> Seems like there's enough hooks in the virtio_net path
> to implement something meaningful and maybe get some numbers (maybe
> ignore NIC aRFS in the first pass).
> 
> Tom
> 
> >>
> >>> Stefan
> >
> >
> >
> > --
> > Regards,
> >
> > Zhi Yong Wu
