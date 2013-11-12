From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 10:12:36 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7400@saturn3.aculab.com>
References: <20131104041108.GA22823@gondor.apana.org.au> <20131106013038.GA14894@gondor.apana.org.au> <20131106123900.GA20259@gondor.apana.org.au> <20131106133045.GA20931@gondor.apana.org.au> <20131106143927.GA21604@gondor.apana.org.au> <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com> <20131107004339.GA28156@gondor.apana.org.au> <20131107062234.GA31156@gondor.apana.org.au> <20131107070335.GA31638@gondor.apana.org.au> <20131107070647.GB31638@gondor.apana.org.au> <20131111185207.GA12277@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	<christoph.paasch@uclouvain.be>, <netdev@vger.kernel.org>,
	<hkchu@google.com>, <mwdalton@google.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54819 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751946Ab3KLKPI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 05:15:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31235-06 for <netdev@vger.kernel.org>;
 Tue, 12 Nov 2013 10:15:04 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131111185207.GA12277@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Recently GRO started generating packets with frag_lists of frags.
> This was not handled by GSO, thus leading to a crash.

Is the build_dma_sg() code in net/usb/usbnet.c correct?
It creates a 'struct scatterlist' array for all the fragments
in and skb.

I'm not at clear of exactly how skb get put together.

	David
 
