From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 09:46:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
References: <20150127.001226.711259930266409202.davem () davemloft ! net>
 <1422349230-17394-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: 'Fan Du' <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:51449 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbbA0Jqf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 04:46:35 -0500
In-Reply-To: <1422349230-17394-1-git-send-email-fan.du@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du
> structure like xfrm_usersa_info or xfrm_userpolicy_info
> has different sizeof when compiled as 32bits and 64bits
> due to not appending pack attribute in their definition.

Don't 'pack' the structure, just ensure that all the fields
are fixed sized and on their natural boundary.

Possibly add a compile-time check that the structure is
of the expected size.

	David
