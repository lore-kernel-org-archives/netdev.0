From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 10:59:05 -0400
Message-ID: <200607151059.05396.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607142202380.19821@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>, sds@epoch.ncsc.mil,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim01.cce.hp.com ([161.114.21.22]:21636 "EHLO
	ccerelrim01.cce.hp.com") by vger.kernel.org with ESMTP
	id S1422630AbWGOO7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 10:59:12 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607142202380.19821@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 July 2006 10:03 pm, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +/**
> > + * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
> >
> > + * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
>
> Can you use lib/bitmap.c instead?

I looked at using the routines in asm/bitopts.h at one point but decided not 
too.  Unfortunately, this was quite some time ago and I can't remember why I 
chose not to use them right now.  I'll look again and if it makes sense I'll 
make the change.

-- 
paul moore
linux security @ hp
