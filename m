From: bert hubert <ahu@ds9a.nl>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 18:24:58 +0100
Message-ID: <20050221172458.GA21715@outpost.ds9a.nl>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com> <20050221120223.GA30348@xi.wantstofly.org> <421A179C.1030505@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <421A179C.1030505@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 06:17:16PM +0100, Christian Schmid wrote:

> Because thats the first I excluded. I changed the program by replacing 
> sendfile with a caching-routine plus syswrite. And it was really 
> interesting that the syswrite was the one which needs most of the 
> real-time, not the caching-routine. syswrite blocked 100 ms per socket.

Do you poll/select for socket readiness before doing write() with EAGAIN?
(shouldn't matter all that much, but could narrow down debugging)

100ms is a bit of an odd number - how big is your write (in bytes)?

Do you have 3500 threads or processes, or one big one?

What does 'id' say in vmstat 1 typically, both below and above 3500 sockets?

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
