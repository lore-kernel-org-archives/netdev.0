From: corbet@lwn.net (Jonathan Corbet)
Subject: Re: [PATCH RFC 1/5] vringfd syscall
Date: Mon, 07 Apr 2008 11:54:34 -0600
Message-ID: <12555.1207590874@vena.lwn.net>
References: <200804052202.09157.rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753293AbYDGRyp@vger.kernel.org>
In-reply-to: Your message of "Sat, 05 Apr 2008 22:02:08 +1000."
             <200804052202.09157.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey, Rusty,

> For virtualization, we've developed virtio_ring for efficient communication.
> This would also work well for userspace-kernel communication, particularly
> for things like the tun device.  By using the same ABI, we can join guests
> to the host kernel trivially.

I'm *sure* you meant to document that somewhat non-trivial proposed new
kernel API as soon as you got a moment.  But, since I went to the
trouble of reverse engineering it, I decided not to wait and to make a
little unreliable guide of my own.  For those who are curious about how
vringfd() is meant to work (or about how badly I misunderstood it), the
info is at:

	http://lwn.net/SubscriberLink/276856/8c927025c53ad7ce/

Hopefully it will be helpful,

jon
