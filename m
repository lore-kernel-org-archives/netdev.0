From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for some PDUs
Date: Thu, 12 May 2011 19:10:12 +0300
Message-ID: <201105121910.13090.vitas@nppfactor.kiev.ua>
References: <201105121557.06679.vitas@nppfactor.kiev.ua> <201105121845.49090.vitas@nppfactor.kiev.ua> <1305215554.6124.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:43100 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757308Ab1ELQKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:10:30 -0400
In-Reply-To: <1305215554.6124.35.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 May 2011 18:52:34 you wrote:
[...]
> What arch needs __packed for
>
> struct mac_addr {
> 	unsigned char addr[6];
> };
>
> ?

Currently I'm working with AT91SAM9260 which is an ARM CPU, and without 
__packed I get sizeof(struct mac_addr) == 8.
