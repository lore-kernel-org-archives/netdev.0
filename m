From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add IP1000A Driver
Date: Tue, 11 Sep 2007 22:32:33 +0200
Message-ID: <20070911203233.GA26577@electric-eye.fr.zoreil.com>
References: <1189524638.3261.1.camel@localhost.localdomain> <20070911164144.2853bcff@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Huang <jesse@icplus.com.tw>, jeff@garzik.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37218 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966315AbXIKUeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 16:34:04 -0400
Content-Disposition: inline
In-Reply-To: <20070911164144.2853bcff@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> :
[...]
> > +	struct {
> > +		u32 field;
> > +		unsigned int len;
> > +	} p[] = {
> > +		{ GMII_PREAMBLE,	32 },	/* Preamble */
> > +		{ GMII_ST,		2  },	/* ST */
> > +		{ GMII_READ,		2  },	/* OP */
> > +		{ phy_id,		5  },	/* PHYAD */
> > +		{ phy_reg,		5  },	/* REGAD */
> > +		{ 0x0000,		2  },	/* TA */
> > +		{ 0x0000,		16 },	/* DATA */
> > +		{ 0x0000,		1  }	/* IDLE */
> > +	};
> 
> This could be declared static const, since it doesn't change.

phy_id and phy_reg do change. It can be worked around but I see
no really nice solution. Any suggestion ?

-- 
Ueimor
