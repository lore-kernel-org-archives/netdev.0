From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 14:20:01 -0700 (PDT)
Message-ID: <20071005.142001.88714271.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932097AbXJEVUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:20:02 -0400
In-Reply-To: <200710051846.19965.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Fri, 5 Oct 2007 18:46:19 +0200

> David Miller schrieb:
> > +#define nr64(reg)		readq(np->regs + (reg))
> > +#define nw64(reg, val)		writeq((val), np->regs + (reg))
> > +
> > +#define nr64_mac(reg)		readq(np->mac_regs + (reg))
> > +#define nw64_mac(reg, val)	writeq((val), np->mac_regs + (reg))
> > +
> > +#define nr64_ipp(reg)		readq(np->regs + np->ipp_off + (reg))
> > +#define nw64_ipp(reg, val)	writeq((val), np->regs + np->ipp_off + (reg))
> > +
> > +#define nr64_pcs(reg)		readq(np->regs + np->pcs_off + (reg))
> > +#define nw64_pcs(reg, val)	writeq((val), np->regs + np->pcs_off + (reg))
> > +
> > +#define nr64_xpcs(reg)		readq(np->regs + np->xpcs_off + (reg))
> > +#define nw64_xpcs(reg, val)	writeq((val), np->regs + np->xpcs_off + (reg))
> 
> Can these be static inline and get the "struct niu *np" passed?

Absolutely not, this was discussed to death in the first review.  This
is a common sequence which is used in several driver, which saves a
lot of typing and carpel-tunnel syndrome.
