From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messag
 es using PF_KEY
Date: Thu, 13 Jul 2006 22:29:02 -0700 (PDT)
Message-ID: <20060713.222902.131918079.davem@davemloft.net>
References: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
	<Pine.LNX.4.64.0607131115130.6169@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	sds@tycho.nsa.gov, tjaeger@cse.psu.edu, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10933
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964795AbWGNF27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:28:59 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607131115130.6169@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 13 Jul 2006 11:18:32 -0400 (EDT)

> I'd suggest assigning the return value to a variable and asserting that, 
> in case defines BUG_ON to nothing and the function won't be called.  Not 
> sure what kernel policy is on this (ISTR people used to worry about it), 
> but it's better not to take uncecessary chances.

There should never be side effects in BUG_ON() checks, just like
an assert().

