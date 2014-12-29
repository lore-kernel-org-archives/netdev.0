From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: net-next + qemu
Date: Mon, 29 Dec 2014 09:03:11 +0200
Message-ID: <20141229070311.GA4803@redhat.com>
References: <CAE4R7bB8Fdx2u+RmX=HAhz8T-GHWtot7fSU-PKCrUYvxMnf0aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbaL2HDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2014 02:03:17 -0500
Content-Disposition: inline
In-Reply-To: <CAE4R7bB8Fdx2u+RmX=HAhz8T-GHWtot7fSU-PKCrUYvxMnf0aQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2014 at 10:48:40PM -0800, Scott Feldman wrote:
> Hi Michael,
> 
> I was doing some testing with latest net-next and latest qemu and
> can't get Linux to load an image when using -drive
> file=xxx.img,if=virtio.  I git bisected net-next and the breakage
> happened on this commit in net-next:
> 
> 38eb4a2 virtio_pci: split out legacy device support
> 
> Qemu image will load if I remove if=virtio.
> 
> Are things in transition right now, and I just got unlucky with this
> combination of net-next and qemu?
> 
> -scott

Yes, if you make virtio-pci modular, it won't load unless
you have this commit:

commit 5ff16110c637726111662c1df41afd9df7ef36bd
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Wed Dec 17 00:54:03 2014 +0200

    virtio_pci: restore module attributes

So v3.19-rc1 is OK, but net-next/master is not.

Dave - will v3.19-rc1 be merged into net-next?
Could you please confirm?

-- 
MST
