From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 14:31:12 +0300
Message-ID: <20060710113112.GA26198@mellanox.co.il>
References: <1152530289.4874.19.camel@laptopd505.fenrus.org>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	Zach Brown <zach.brown@oracle.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v67.mxlogic.net ([208.65.145.67]:16772 "EHLO
	p02c11o144.mxlogic.net") by vger.kernel.org with ESMTP
	id S932314AbWGJLaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 07:30:52 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1152530289.4874.19.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Arjan van de Ven <arjan@infradead.org>:
> Subject: Re: [PATCH] IB/mthca: comment fix
> 
> On Mon, 2006-07-10 at 14:14 +0300, Michael S. Tsirkin wrote:
> > Hi Andrew,
> > Here's a cosmetic patch for IB/mthca. Pls drop it into -mm and on.
> > 
> > ---
> > 
> > comment in mthca_qp.c makes it seem lockdep is the only reason WQ locks should
> > be initialized separately, but as Zach Brown and Roland pointed out, there are
> > other reasons, e.g. that mthca_wq_init is called from modify qp as well.
> 
> ehh.. shouldn't the comment say that instead then? that's one tricky
> thing and might as well have that documented in the code!

Hmm. Okay. Maybe we should rename mthca_wq_init to mthca_wq_reset?
This would make it clear that it does not init the spinlocks,
but just resets the rest of the fields, would not it?

How does this sound?

-- 
MST
