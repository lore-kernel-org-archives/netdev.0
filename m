From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Wed, 20 Jan 2016 19:11:17 +0000
Message-ID: <8BD201BE-E272-4BA7-ABB4-8FDCE139495D@intel.com>
References: <56901197.8040808@solarflare.com>
 <56901235.1010800@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
 <5693AC59.4080702@solarflare.com>
 <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_BC1AD899-881F-40FC-A1D9-F4A028BD73DF";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Edward Cree <ecree@solarflare.com>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6284 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920AbcATTLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 14:11:18 -0500
In-Reply-To: <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_BC1AD899-881F-40FC-A1D9-F4A028BD73DF
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Actually you may want to go the other way on that.  If they weren't
> flipping the checksum value for GRE before why should we start doing
> that now?  I'm pretty sure the checksum mangling is a very UDP centric
> thing.  There is no need to introduce it to other protocols.

If different checksum representations are needed, then there really should  
be an explicit indication of whether it is a UDP-style checksum or other in  
the skb I would think rather than guessing it based on the offset. Of  
course it would be convenient if all the protocols that use a one's  
complement checksum would tolerate the UDP representation. I have a long  
(and now old) history working with real one's complement machines, and so I  
would want to believe that any correct implementation would tolerate it,  
but I don't know for a fact that they do.
--Apple-Mail=_BC1AD899-881F-40FC-A1D9-F4A028BD73DF--
