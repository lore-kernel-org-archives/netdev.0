From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 13:45:03 +0200
Message-ID: <1152531909.4874.22.camel@laptopd505.fenrus.org>
References: <1152530289.4874.19.camel@laptopd505.fenrus.org>
	 <20060710113112.GA26198@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	Zach Brown <zach.brown@oracle.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:63362 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S964912AbWGJLpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 07:45:25 -0400
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20060710113112.GA26198@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-10 at 14:31 +0300, Michael S. Tsirkin wrote:
> Quoting r. Arjan van de Ven <arjan@infradead.org>:
> > Subject: Re: [PATCH] IB/mthca: comment fix
> > 
> > On Mon, 2006-07-10 at 14:14 +0300, Michael S. Tsirkin wrote:
> > > Hi Andrew,
> > > Here's a cosmetic patch for IB/mthca. Pls drop it into -mm and on.
> > > 
> > > ---
> > > 
> > > comment in mthca_qp.c makes it seem lockdep is the only reason WQ locks should
> > > be initialized separately, but as Zach Brown and Roland pointed out, there are
> > > other reasons, e.g. that mthca_wq_init is called from modify qp as well.
> > 
> > ehh.. shouldn't the comment say that instead then? that's one tricky
> > thing and might as well have that documented in the code!
> 
> Hmm. Okay. Maybe we should rename mthca_wq_init to mthca_wq_reset?
> This would make it clear that it does not init the spinlocks,
> but just resets the rest of the fields, would not it?

makes sense to me; my main concern is that we document the bug that was
there; unless you document such things.. these bugs tend to have a habit
of resurfacing later ;)

