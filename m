From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 19:54:11 +0800
Message-ID: <20100719115411.GA22758@gondor.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au> <20100610074912.1303e3da@nehalam> <20100610215643.GA22048@gondor.apana.org.au> <20100610145915.721a86b7@nehalam> <20100610224839.GA22469@gondor.apana.org.au> <20100611021142.GA24490@gondor.apana.org.au> <20100719101904.GA31743@redhat.com> <20100719105300.GA22179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59808 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760598Ab0GSLyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 07:54:19 -0400
Content-Disposition: inline
In-Reply-To: <20100719105300.GA22179@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 06:53:00PM +0800, Herbert Xu wrote:
>
> > Meanwhile, should we just disable netpoll for bridge in 2.6.35 and -stable?
> > We are getting crash reports in virtualization which I suspect are
> > related to this:
> > https://bugzilla.kernel.org/show_bug.cgi?id=16413
> 
> I think that's probably the best solution, Dave?

I take that back :)

It turns out that 16413 has nothing to do with bridge netpoll
(which was not merged until after 2.6.34) since he's running
2.6.34.

Still, it might be a good idea to disable bridge netpoll in
2.6.35.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
