From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sun, 16 Jul 2006 18:12:30 -0700 (PDT)
Message-ID: <20060716.181230.59471240.davem@davemloft.net>
References: <20060714185915.270209000@flek.zko.hp.com>
	<Pine.LNX.4.64.0607142202380.19821@d.namei>
	<200607161210.44873.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@epoch.ncsc.mil, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28645
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751494AbWGQBMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 21:12:14 -0400
To: paul.moore@hp.com
In-Reply-To: <200607161210.44873.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Sun, 16 Jul 2006 12:10:44 -0400

> On Friday 14 July 2006 10:03 pm, James Morris wrote:
> > On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > > +/**
> > > + * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
> > >
> > > + * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
> >
> > Can you use lib/bitmap.c instead?
>
> Looking again at include/asm/bitops.h I think I now remember why I
> decided not to use them in the first place.

lib/bitmap.c and the asm/bitops.h operations are two entirely
different animals.

Wrt. your asm/bitops.h concerns, is there any reason you cannot pad
out your bitmaps to be a modulo of "long" which is required for
those routines?

