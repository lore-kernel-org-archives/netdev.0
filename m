From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for
 some PDUs
Date: Thu, 12 May 2011 08:52:34 -0700
Message-ID: <1305215554.6124.35.camel@Joe-Laptop>
References: <201105121557.06679.vitas@nppfactor.kiev.ua>
	 <1305210816.5214.9.camel@bwh-desktop>
	 <201105121845.49090.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1551 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335Ab1ELPwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 11:52:35 -0400
In-Reply-To: <201105121845.49090.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 18:45 +0300, Vitalii Demianets wrote:
> On Thursday 12 May 2011 17:33:36 Ben Hutchings wrote:
> [...]
> > The '__packed' macro is preferred.
> Also, I'm slightly in doubt if I should split the patch in 2 parts, one for 
> bonding an one for LLC?

What arch needs __packed for

struct mac_addr {
	unsigned char addr[6];
};

?

