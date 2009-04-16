From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: performance regression in 2.6.30-rc1
Date: Fri, 17 Apr 2009 07:51:00 +0800
Message-ID: <20090416235100.GD29988@gondor.apana.org.au>
References: <20090416213122.GB5894@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40476 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757543AbZDPXvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:51:07 -0400
Content-Disposition: inline
In-Reply-To: <20090416213122.GB5894@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 12:31:22AM +0300, Michael S. Tsirkin wrote:
> Hi,
> I have a simple test that sends 10K packets out of a tap device.  Average time
> needed to send a packet has gone up from 2.6.29 to 2.6.30-rc1.
> 
> 2.6.30-rc1:
> 
> #sh runsend
> time per packet:       7570 ns
> 
> 2.6.29:
> 
> #git checkout v2.6.29 -- drivers/net/tun.c
> #make modules modules_install
> #rmmod tun
> #sh runsend
> time per packet:       6337 ns
> 
> I note that before 2.6.29, all tun skbs would typically be linear,
> while in 2.6.30-rc1, skbs for packet size > 1 page would be paged.
> And I found this comment by Rusty (it appears in the comment for
> commit f42157cb568c1eb02eca7df4da67553a9edae24a):

Again this should already be fixed in the latest net-2.6.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
