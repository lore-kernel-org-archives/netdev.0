From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 13:36:53 +0100
Message-ID: <20050221123653.GA30508@xi.wantstofly.org>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com> <20050221120223.GA30348@xi.wantstofly.org> <20050221122540.GA13973@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <ahu@ds9a.nl>, Christian Schmid <webmaster@rapidforum.com>,
        Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050221122540.GA13973@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 01:25:41PM +0100, bert hubert wrote:

> > O_NONBLOCK send() is really nonblocking, but O_NONBLOCK sendfile()
> 
> It is? So it returns EAGAIN if the data to be sent is not in the
> page cache?

No, it just blocks.  It only returns EAGAIN if the data is in the
page cache but the socket TX queue doesn't have enough space.  (At
least, when I last tried it.)


--L
