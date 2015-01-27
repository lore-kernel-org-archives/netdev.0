From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 12:04:13 +0100
Message-ID: <20150127110413.GF1373@breakpoint.cc>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Fan Du' <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59803 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbbA0LE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 06:04:29 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Fan Du
> > structure like xfrm_usersa_info or xfrm_userpolicy_info
> > has different sizeof when compiled as 32bits and 64bits
> > due to not appending pack attribute in their definition.
> 
> Don't 'pack' the structure, just ensure that all the fields
> are fixed sized and on their natural boundary.

How do you propose to do this without breaking ABI?

> Possibly add a compile-time check that the structure is
> of the expected size.

Uh, what?
