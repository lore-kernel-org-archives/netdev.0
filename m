From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 18:29:43 +0100
Message-ID: <20050221172943.GA31814@xi.wantstofly.org>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com> <20050221120223.GA30348@xi.wantstofly.org> <421A179C.1030505@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <ahu@ds9a.nl>, Nivedita Singhvi <niv@us.ibm.com>,
        netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <421A179C.1030505@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 06:17:16PM +0100, Christian Schmid wrote:

> >>Outgoing data. I am using sendfile() to send the file on a non-blocking 
> >>socket but the call blocks for 100 ms per socket if I get over 3000 
> >>sockets. Thats causing the massive slowdown in sum. I first thought its a 
> >>disk-issue but I tried with pure-cache data as well and it still blocks.
> >
> >O_NONBLOCK send() is really nonblocking, but O_NONBLOCK sendfile()
> >really isn't, as it still does the disk read (if any) synchronously.
> >
> >How are you making sure that you're sending "pure-cache data"?
> 
> Because thats the first I excluded. I changed the program by replacing 
> sendfile with a caching-routine plus syswrite. And it was really 
> interesting that the syswrite was the one which needs most of the 
> real-time, not the caching-routine. syswrite blocked 100 ms per socket.

'syswrite'.

Is your application written in C or perl?


--L
