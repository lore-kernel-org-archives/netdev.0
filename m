From: David Miller <davem@davemloft.net>
Subject: Re: virtio_net: MAC address releated breakage if there is no MAC
 area in config
Date: Sat, 04 Apr 2009 16:40:31 -0700 (PDT)
Message-ID: <20090404.164031.03580665.davem@davemloft.net>
References: <200904021333.25119.borntraeger@de.ibm.com>
	<1238688385.6124.255.camel@bling>
	<200904021923.48907.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: borntraeger@de.ibm.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200904021923.48907.borntraeger@de.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 2 Apr 2009 19:23:48 +0200

> Am Thursday 02 April 2009 18:06:25 schrieb Alex Williamson:
> > virtio_net: Set the mac config only when VIRITO_NET_F_MAC
> > 
> > VIRTIO_NET_F_MAC indicates the presence of the mac field in config
> > space, not the validity of the value it contains.  Allow the mac to be
> > changed at runtime, but only push the change into config space with the
> > VIRTIO_NET_F_MAC feature present.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> 
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

Applied, thanks!
