From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 22:17:18 +0530
Message-ID: <OF025FB4DD.0A1D8CAD-ON65257798.00527BE1-65257798.005C0247@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <4C875735.9050808@redhat.com> <OFAA7EBCA4.A8F764FD-ON65257798.0035E8C2-65257798.00385450@in.ibm.com> <201009081612.41976.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, Avi Kivity <avi@redhat.com>,
	davem@davemloft.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:44542 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471Ab0IHQpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 12:45:05 -0400
In-Reply-To: <201009081612.41976.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wednesday 08 September 2010, Krishna Kumar2 wrote:
> > > The new guest and qemu code work with old vhost-net, just with
reduced
> > > performance, yes?
> >
> > Yes, I have tested new guest/qemu with old vhost but using
> > #numtxqs=1 (or not passing any arguments at all to qemu to
> > enable MQ). Giving numtxqs > 1 fails with ENOBUFS in vhost,
> > since vhost_net_set_backend in the unmodified vhost checks
> > for boundary overflow.
> >
> > I have also tested running an unmodified guest with new
> > vhost/qemu, but qemu should not specify numtxqs>1.
>
> Can you live migrate a new guest from new-qemu/new-kernel
> to old-qemu/old-kernel, new-qemu/old-kernel and old-qemu/new-kernel?
> If not, do we need to support all those cases?

I have not tried this, though I added some minimal code in
virtio_net_load and virtio_net_save. I don't know what needs
to be done exactly at this time. I forgot to put this in the
"Next steps" list of things to do.

Thanks,

- KK

