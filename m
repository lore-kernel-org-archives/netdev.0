From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for
 some PDUs
Date: Thu, 12 May 2011 09:16:13 -0700
Message-ID: <1305216973.6124.43.camel@Joe-Laptop>
References: <201105121557.06679.vitas@nppfactor.kiev.ua>
	 <201105121845.49090.vitas@nppfactor.kiev.ua>
	 <1305215554.6124.35.camel@Joe-Laptop>
	 <201105121910.13090.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org,
	bonding-devel <bonding-devel@lists.sourceforge.net>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1560 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756164Ab1ELQQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:16:14 -0400
In-Reply-To: <201105121910.13090.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 19:10 +0300, Vitalii Demianets wrote:
> On Thursday 12 May 2011 18:52:34 you wrote:
> [...]
> > What arch needs __packed for
> > struct mac_addr {
> > 	unsigned char addr[6];
> > };
> > ?
> Currently I'm working with AT91SAM9260 which is an ARM CPU, and without 
> __packed I get sizeof(struct mac_addr) == 8.

Thanks.

