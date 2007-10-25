From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error statistics.
Date: Thu, 25 Oct 2007 18:06:07 +0900
Message-ID: <200710251806.07958.nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net> <200710241230.57571.nakam@linux-ipv6.org> <1193228326.4442.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:52664 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755113AbXJYJGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 05:06:18 -0400
In-Reply-To: <1193228326.4442.12.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wednesday 24 October 2007 21:18, jamal wrote:
> On Wed, 2007-24-10 at 12:30 +0900, Masahide NAKAMURA wrote:
> 
> > At IPsec point of view, actually "SPI mismatch" caused by user configuration
> > cannot be identified easily since identify of SAD is consist of SPI, address and
> > protocol(ESP/AH...) and linux SAD uses hash database. It is database identify
> > mismatch. Then, SPI mismatch goes "NoStates" at my patch.
> > OTOH Key mismatch goes "ProtoError" since esp[46]_input returns error.
> 
> Would be useful to just document what you said above so that user doesnt
> have to intepret it.

OK, I write it to commit-log then. If anybody have another place
where such information should be written, tell me.

[snip]
> > > In any case, it seems to me to be more accurate to not call them MIB
> > > stats if they are not. This doesnt qualify using the macros, utilities
> > > etc used for MIBs.
> > 
> 
> BTW, I meant "doesnt disqualify them" above;-> 

OK ;-)

Jamal, thanks for many comments.

-- 
Masahide NAKAMURA
