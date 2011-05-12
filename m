From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for some PDUs
Date: Thu, 12 May 2011 18:45:48 +0300
Message-ID: <201105121845.49090.vitas@nppfactor.kiev.ua>
References: <201105121557.06679.vitas@nppfactor.kiev.ua> <1305210816.5214.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:50639 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756164Ab1ELPqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 11:46:12 -0400
In-Reply-To: <1305210816.5214.9.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 May 2011 17:33:36 Ben Hutchings wrote:
[...]
> The '__packed' macro is preferred.

Ok, it looks more compatible, i"ll resubmit the patch with this macro.

Also, I'm slightly in doubt if I should split the patch in 2 parts, one for 
bonding an one for LLC?
