From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Fri, 11 Apr 2014 08:45:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F5DE1@AcuExch.aculab.com>
References: <20140407142334.GA28814@gondor.apana.org.au>
 <53442868.3090701@candelatech.com>
 <20140408172349.GA7147@gondor.apana.org.au>
 <20140410.214023.849284639345029049.davem@davemloft.net>
 <20140411015906.GB31251@gondor.apana.org.au>
 <1397182170.16584.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140411021300.GA31748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"greearb@candelatech.com" <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55668 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750817AbaDKIrV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 04:47:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24132-01 for <netdev@vger.kernel.org>;
 Fri, 11 Apr 2014 09:47:11 +0100 (BST)
In-Reply-To: <20140411021300.GA31748@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > ARP filter would require to inspect the queried IPv4 address, and
> > macvlan do not currently have a list of IPv4 addresses per port.
> 
> Indeed.  Thanks for snapping us out of our collective daydream :)

You could save the info from ARP responses.

Whether you want that much layer-breaking is another matter.
By the sound of it, it might be worth doing the deep packet
inspection at startup.

	David
