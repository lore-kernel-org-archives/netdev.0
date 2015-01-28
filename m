From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Wed, 28 Jan 2015 09:53:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD480D@AcuExch.aculab.com>
References: <20150127.001226.711259930266409202.davem_()_davemloft_!_net>
	<1422349230-17394-1-git-send-email-fan.du@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
 <20150127.112406.159033030097516231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "fan.du@intel.com" <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:55500 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679AbbA2Dr4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 22:47:56 -0500
In-Reply-To: <20150127.112406.159033030097516231.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Tue, 27 Jan 2015 09:46:21 +0000
> 
> > From: Fan Du
> >> structure like xfrm_usersa_info or xfrm_userpolicy_info
> >> has different sizeof when compiled as 32bits and 64bits
> >> due to not appending pack attribute in their definition.
> >
> > Don't 'pack' the structure, just ensure that all the fields
> > are fixed sized and on their natural boundary.
> 
> This horse went out of the door more than a decade ago, we can't
> change the layout of any of these structures and must at some point
> add code to translate instead.

>From the other mail it might just be tail-padding.
So any adaption code is easy.

	David
