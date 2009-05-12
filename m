From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 12 May 2009 20:15:20 +0200
Message-ID: <20090512181520.GL19296@one.firstfloor.org>
References: <1242076914.12380.2.camel@bender> <87octymhbt.fsf@basil.nowhere.org> <7e0dd21a0905121058m1f894de6q9805e5392aef3aea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johann Baudy <johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7e0dd21a0905121058m1f894de6q9805e5392aef3aea-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[full quote for linux-man, Michael]

On Tue, May 12, 2009 at 07:58:06PM +0200, Johann Baudy wrote:
> Hi Andi,
> 
> Currently, There is nothing in the manpage of packet(7) about RX_RING.

Yes mmap was never documented. But if you could do that that would
be great.

> However I can start to write a summary  that describes processes, headers
> and statuses of both feature (RX_RING and TX_RING).
> I think "Socket Options" section of packet(7) is appropriate.

Sounds good. Please send the result to linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

-Andi

> 
> Johann
> 
> 
> On Tue, May 12, 2009 at 6:11 PM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrote:
> 
> > Johann Baudy <johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org> writes:
> >
> > > From: Johann Baudy <johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org>
> > >
> > > New packet socket feature that makes packet socket more efficient for
> > transmission.
> > > - It reduces number of system call through a PACKET_TX_RING mechanism,
> > based on PACKET_RX_RING (Circular buffer allocated in kernel space which is
> > mmapped from user space).
> > > - It minimizes CPU copy using fragmented SKB (almost zero copy).
> >
> > When you add new interfaces like this you should add them to the packet (7)
> > manpage too.
> >
> > -Andi
> >
> > --
> > ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org -- Speaking for myself only.
> >

-- 
ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org -- Speaking for myself only.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
