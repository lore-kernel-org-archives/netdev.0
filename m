From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 8 Aug 2002 17:07:20 +0100
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808170720.N24631@parcelfarce.linux.theplanet.co.uk>
References: <Mutt.LNX.4.44.0208081018410.16830-100000@blackbird.intercode.com.au> <20020808.083320.100990288.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   willy@debian.org
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020808.083320.100990288.davem@redhat.com>; from davem@redhat.com on Thu, Aug 08, 2002 at 08:33:20AM -0700
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2002 at 08:33:20AM -0700, David S. Miller wrote:
>    From: James Morris <jmorris@intercode.com.au>
>    Date: Thu, 8 Aug 2002 10:24:19 +1000 (EST)
> 
>    Suggested by Matthew Wilcox, the patch below consolidates FIOSETOWN etc. 
>    ioctl handling into the socket layer, making it common for all sockets.
> 
> Do we really want to do this?  What if some socket family either
> doesn't want to support it or wants to handle it differently?

I rather think we do.  It's analagous to saying "What if some filesystem
either doesn't want to support it or wants to handle it differently?"
-- tough!  This is unix and filesystems (socket families) support this.

have you read forsyth's paper "Sending UNIX to the Fat Farm"?
http://www.caldo.demon.co.uk/doc/taste.pdf
Section 3.3 is relevant here ... though I think you'll find great
amusement in his other criticisms of solaris.

-- 
Revolutions do not require corporate support.
