From: Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] ip.7: Improve explanation about calling listen or
 connect
Date: Wed, 6 Jun 2012 11:44:26 -0300
Message-ID: <20120606114426.0595fbac@asterix.rh>
References: <1336566636-14713-1-git-send-email-fbl@redhat.com>
	<4FBF66D8.7060007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Schiffer <pschiffe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FBF66D8.7060007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi,

Could someone tell me what's the patch current state?
It has been a month already with no feedback.
thanks,
fbl

On Fri, 25 May 2012 13:02:48 +0200
Peter Schiffer <pschiffe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Hi Michael,
> 
> do you have any comments for this update? Or do you need some supporting 
> info?
> 
> peter
> 
> On 05/09/2012 02:30 PM, Flavio Leitner wrote:
> > Signed-off-by: Flavio Leitner<fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > ---
> >   man7/ip.7 |   15 +++++++++------
> >   1 files changed, 9 insertions(+), 6 deletions(-)
> >
> > diff --git a/man7/ip.7 b/man7/ip.7
> > index 9f560df..84fe32d 100644
> > --- a/man7/ip.7
> > +++ b/man7/ip.7
> > @@ -69,12 +69,11 @@ For
> >   you may specify a valid IANA IP protocol defined in
> >   RFC\ 1700 assigned numbers.
> >   .PP
> > -.\" FIXME ip current does an autobind in listen, but I'm not sure
> > -.\" if that should be documented.
> >   When a process wants to receive new incoming packets or connections, it
> >   should bind a socket to a local interface address using
> >   .BR bind (2).
> > -Only one IP socket may be bound to any given local (address, port) pair.
> > +In this case, only one IP socket may be bound to any given local
> > +(address, port) pair.
> >   When
> >   .B INADDR_ANY
> >   is specified in the bind call, the socket will be bound to
> > @@ -82,10 +81,14 @@ is specified in the bind call, the socket will be bound to
> >   local interfaces.
> >   When
> >   .BR listen (2)
> > -or
> > +is called on an unbound socket, the socket is automatically bound
> > +to a random free port with the local address set to
> > +.BR INADDR_ANY .
> > +When
> >   .BR connect (2)
> > -are called on an unbound socket, it is automatically bound to a
> > -random free port with the local address set to
> > +is called on an unbound socket, the socket is automatically bound
> > +to a random free port or an usable shared port with the local address
> > +set to
> >   .BR INADDR_ANY .
> >
> >   A TCP local socket address that has been bound is unavailable for

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
