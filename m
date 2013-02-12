From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Tue, 12 Feb 2013 12:43:31 +0200
Message-ID: <20130212104331.GA23495@redhat.com>
References: <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
 <20121123110146.GC7051@redhat.com>
 <50FE5607.9020405@dlhnet.de>
 <20130123100312.GA8108@redhat.com>
 <5119E9DC.3000505@dlhnet.de>
 <20130212090850.GB22029@redhat.com>
 <056542E4-18E4-4C9F-AC96-60661768D6AF@dlhnet.de>
 <511A0DBB.7080907@msgid.tls.msk.ru>
 <20130212095422.GA23270@redhat.com>
 <D40E1487-27E9-40B3-B007-085B432E5600@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: Peter Lieven <pl@dlhnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932696Ab3BLKjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 05:39:04 -0500
Content-Disposition: inline
In-Reply-To: <D40E1487-27E9-40B3-B007-085B432E5600@dlhnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 11:11:45AM +0100, Peter Lieven wrote:
> 
> Am 12.02.2013 um 10:54 schrieb "Michael S. Tsirkin" <mst@redhat.com>:
> 
> > On Tue, Feb 12, 2013 at 01:39:07PM +0400, Michael Tokarev wrote:
> >> 12.02.2013 13:10, Peter Lieven wrote:
> >> []
> >> 
> >> Guys, can we please trim the excessive quoting just a bit? ;)
> >> 
> >>>>> If have set this option for 2 weeks now and not seen this problem again.
> >>>>> How does this flag work with the recently added tap multiqueue support?
> >> 
> >>>> This will be the only option in 3.8.
> >> 
> >>> Ok, but wouldn`t it be good to set it in qemu for kernels <3.8?
> >> 
> >> I'd say for kernels without mq support, not for <3.8, right? :)
> >> 
> >> Thanks,
> >> 
> >> /mjt
> > 
> > It's harmless to always set this flag, on 3.8 it does nothing.
> 
> And kernels <3.8 do not have multi queue support?
> 
> Peter

Let's be specific. Multiqueue support in qemu uses TUNSETQUEUE ioctl.
No kernel released by Linus so far has support for this ioctl in tun device,
but it has been merged so should be in 3.8.

> > 
> > -- 
> > MST
