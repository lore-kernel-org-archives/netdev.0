From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] af_packet: Add PACKET_FANOUT_QM documentation
Date: Sun, 23 Feb 2014 17:23:21 -0500
Message-ID: <20140223222321.GA14507@neilslaptop.think-freely.org>
References: <1390911375-5784-1-git-send-email-nhorman@tuxdriver.com>
 <53087188.9080408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53087188.9080408-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 22, 2014 at 10:44:40AM +0100, Michael Kerrisk (man-pages) wrote:
> On 01/28/2014 01:16 PM, Neil Horman wrote:
> > Recently added a new fanout mode of operation to packet sockets.  Document it
> > here
> 
> Thanks, Neil. Applied.
> 
> This new mode is ne win 3.14, right?
> 
IIRC, yes, thats correct.
Neil

> Cheers,
> 
> Michael
> 
> 
> > Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > CC: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> > CC: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org
> > CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > ---
> >  man7/packet.7 | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/man7/packet.7 b/man7/packet.7
> > index 93f91e9..6e145dc 100644
> > --- a/man7/packet.7
> > +++ b/man7/packet.7
> > @@ -296,6 +296,8 @@ processes all data on a single socket, moves to the next when one
> >  becomes backlogged.
> >  .BR PACKET_FANOUT_RND
> >  selects the socket using a pseudo-random number generator.
> > +.BR PACKET_FANOUT_QM
> > +selects the socket using the recorded queue_mapping of the received skb.
> >  
> >  Fanout modes can take additional options.
> >  IP fragmentation causes packets from the same flow to have different
> > 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
