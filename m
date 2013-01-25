From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Fri, 25 Jan 2013 13:33:34 -0800 (PST)
Message-ID: <362258122.36962636.1359149614436.JavaMail.root@vmware.com>
References: <1426158581.24554896.1357785777229.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426158581.24554896.1357785777229.JavaMail.root@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > Our position is that VSOCK feature set is more complete and that
> > > it
> > > should be possible to use transports other than VMCI for VSOCK
> > > traffic, should interested parties implement them,
> > 
> > Implementing other transports requires restructing vsock (and vmci)
> > first as the current vsock code is not a hypervisor neutral
> > service.
> 
> I'm going to bite the bullet and spend the next couple of days doing
> just that: factoring out the VMCI bits and hiding them behind a
> transport layer.  It'll be a bit rough, but it'll be a start.  We'll
> submit another patch series next week with that.  I'm hoping that'll
> get us over this hump, since it should by hypervisor agnostic at
> that point.  It'll be up to you guys to add virtio, though :)

I sent out a patch series this morning that splits out our code into a
core part, containing the socket family/operations, and a VMCI-specific
part.  The core makes callbacks via a new transport layer into VMCI.
It's not perfect -- there's still some cruft in the core socket
structure -- but it lays the foundation of a hypervisor-neutral channel,
and hopefully we can build on this with your help.  It'd be great if
you could take a look.

Thanks!
- Andy
