From: Andries Brouwer <Andries.Brouwer@cwi.nl>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 8 Jul 2004 21:05:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708190530.GA18139@apps.cwi.nl>
References: <20040708170705.GA6895@apps.cwi.nl> <40ED936F.9000905@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andries Brouwer <Andries.Brouwer@cwi.nl>, Andi Kleen <ak@suse.de>,
        Michael T Kerrisk <mtk-lists@gmx.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <40ED936F.9000905@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 02:33:19PM -0400, Chris Friesen wrote:
> Andries Brouwer wrote:
> >Can you find the man-pages-1.67 package and construct a concrete patch?
> >
> >(Don't know precisely what you want to do. The above gives a filename
> >recv.man, which would be recv.2 in my sources. But there is no MSG_NOSIGNAL
> >in recv.2, only in send.2. The fragment of text that you give occurs
> >already in recv.2.)
> 
> Working from the webpage at:
> 
> http://homepages.cwi.nl/~aeb/linux/man2html/man2/recv.2.html

Ah, that is how I am punished for neglecting to update these html pages :-)
Will update them.

I was confused by your MSG_NOSIGNAL, but indeed, that is still on that page,
it was removed later.

Have moved the MSG_DONTWAIT part to after the MSG_WAITALL description.
[Will still check whether that is really appropriate.]

Thanks!

Andries
