From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH 1/3] Fix ERROR: trailing statements should be on next line
Date: Sun, 14 May 2017 21:20:48 -0600
Message-ID: <20170514212048.24ee7667@t450s.home>
References: <20170514175130.18664-1-macfij7@wp.pl>
	<20170515055700-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Maciek Fijalkowski <macfij7@wp.pl>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170515055700-mutt-send-email-mst@kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2017 05:58:05 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Sun, May 14, 2017 at 07:51:28PM +0200, Maciek Fijalkowski wrote:
> > From: Maciej Fijalkowski <macfij7@wp.pl>
> > 
> > Signed-off-by: Maciej Fijalkowski <macfij7@wp.pl>  
> 
> I prefer the original form - ; isn't a full statement.
> 
> > ---
> >  drivers/net/virtio_net.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 9320d96..f20dfb8 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -217,7 +217,8 @@ static void give_pages(struct receive_queue *rq, struct page *page)
> >  	struct page *end;
> >  
> >  	/* Find end of list, sew whole thing into vi->rq.pages. */
> > -	for (end = page; end->private; end = (struct page *)end->private);
> > +	for (end = page; end->private; end = (struct page *)end->private)
> > +		;

FWIW, I generally like to put a comment on the next line to make it
abundantly clear that there's nothing in the body of the loop, it's
also more aesthetically pleasing than a semi-colon on the line by
itself, ex. /* Nothing */;  It's just too easy to misinterpret the
loop otherwise, especially without gratuitous white space.  Thanks,

Alex


> >  	end->private = (unsigned long)rq->pages;
> >  	rq->pages = page;
> >  }
> > -- 
> > 2.4.11  
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
