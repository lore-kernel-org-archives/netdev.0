From: Andries Brouwer <Andries.Brouwer@cwi.nl>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 8 Jul 2004 19:07:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708170705.GA6895@apps.cwi.nl>
References: <20040708162703.GA12934@wotan.suse.de> <40ED7B18.800@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andries.Brouwer@cwi.nl, Andi Kleen <ak@suse.de>,
        Michael T Kerrisk <mtk-lists@gmx.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <40ED7B18.800@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 12:49:28PM -0400, Chris Friesen wrote:

> > > why its not in the man pages?
> >
> >Nobody ever added it? Just send a patch to aeb@cwi.nl
> 
> Sending patch as suggested.  Fundamentally, the delta is as follows, I've 
> included an attachment with what I hope are the proper formatting codes 
> (copied from send(2)).
> 
> --- recv.man    2004-07-08 15:43:17.000000000 -0400
> +++ recv2.man   2004-07-08 15:47:29.000000000 -0400
> @@ -67,6 +67,11 @@
>                disconnect occurs, or the next data to be received is of a  
>                dif-
>                ferent type than that returned.
> 
> +       MSG_DONTWAIT
> +              Enables  non-blocking  operation;  if the operation would 
> block,
> +              EAGAIN is returned (this can also be enabled  using  the  
> O_NON-
> +              BLOCK with the F_SETFL fcntl(2)).
> +
>         MSG_NOSIGNAL
>                This  flag  turns  off raising of SIGPIPE on stream sockets 
>                when
>                the other end disappears.
> 
> 
> Note also that there is a mention of MSG_DONTWAIT in the msg_flags field in 
> the msghdr.  It gives the impression that one can *set* that field to cause 
> the non-blocking behaviour.  My understanding is that the msg_flags field 
> is a return value only.  Perhaps that portion should be reworded as well.
> 
> Chris


Can you find the man-pages-1.67 package and construct a concrete patch?

(Don't know precisely what you want to do. The above gives a filename
recv.man, which would be recv.2 in my sources. But there is no MSG_NOSIGNAL
in recv.2, only in send.2. The fragment of text that you give occurs
already in recv.2.)

Andries
