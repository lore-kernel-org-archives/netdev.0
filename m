From: bert hubert <ahu@ds9a.nl>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 13:25:41 +0100
Message-ID: <20050221122540.GA13973@outpost.ds9a.nl>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com> <20050221120223.GA30348@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Schmid <webmaster@rapidforum.com>,
        Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20050221120223.GA30348@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 01:02:23PM +0100, Lennert Buytenhek wrote:
> O_NONBLOCK send() is really nonblocking, but O_NONBLOCK sendfile()

It is? So it returns EAGAIN if the data to be sent is not in the page cache?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
