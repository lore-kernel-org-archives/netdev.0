From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 9 Sep 2010 18:49:26 +0530
Message-ID: <OF7CA2E082.15B00FF0-ON65257799.0041FC03-65257799.0048F9D6@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009081612.41976.arnd@arndb.de> <OF025FB4DD.0A1D8CAD-ON65257798.00527BE1-65257798.005C0247@in.ibm.com> <201009091240.27969.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, Avi Kivity <avi@redhat.com>,
	davem@davemloft.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:48021 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab0IINRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:17:12 -0400
In-Reply-To: <201009091240.27969.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote on 09/09/2010 04:10:27 PM:

> > > Can you live migrate a new guest from new-qemu/new-kernel
> > > to old-qemu/old-kernel, new-qemu/old-kernel and old-qemu/new-kernel?
> > > If not, do we need to support all those cases?
> >
> > I have not tried this, though I added some minimal code in
> > virtio_net_load and virtio_net_save. I don't know what needs
> > to be done exactly at this time. I forgot to put this in the
> > "Next steps" list of things to do.
>
> I was mostly trying to find out if you think it should work
> or if there are specific reasons why it would not.
> E.g. when migrating to a machine that has an old qemu, the guest
> gets reduced to a single queue, but it's not clear to me how
> it can learn about this, or if it can get hidden by the outbound
> qemu.

I agree, I am also not sure how the old guest will handle this.
Sorry about my ignorance on migration :(

Regards,

- KK

