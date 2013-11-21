From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 21 Nov 2013 13:17:32 +0100
Message-ID: <20131121121732.GE31491@secunet.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131107112549.GP31491@secunet.com>
 <527B8DC5.6080702@6wind.com>
 <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
 <528B2C72.5060809@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saurabh Mohan <saurabh.mohan@brocade.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33837 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491Ab3KUMRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 07:17:34 -0500
Content-Disposition: inline
In-Reply-To: <528B2C72.5060809@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 05:16:34PM +0800, Fan Du wrote:
> 
> Or the VTI tunnel is the only tunnel with this specific source/destination address
> in the production deployment. Again the upper layer 4 will check the policy after
> all, that's the right place to do the policy checking.
> 
> So IMO, it's unnecessary to check policy for a net_device like VTI, actually I hold
> a patch of removing the VTI policy checking due to net-next closure for the moment.
> 

Please keep in mind that this will change the lookup from the
IPsec traffic to the plaintext traffic, like Christophe proposed
to do. This means that the transmit side has to be changed too.
