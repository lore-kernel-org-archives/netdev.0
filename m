From: bert hubert <ahu@ds9a.nl>
Subject: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 10:01:21 +0100
Message-ID: <20050221090121.GA7478@outpost.ds9a.nl>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <42192CD5.5090401@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 01:35:33AM +0100, Christian Schmid wrote:

> New connections get made without any problems. Just existing connections 
> slow down painfully.

Incoming our outgoing data mostly?

> 3000 sockets = no slowdown at all (500 MBit in use)
> 3300 sockets = 10% slowdown
> 3600 sockets = 30% slowdown
> 4000 sockets = 60% slowdown (i aborted here, as it only uses 200 MBit for 
> sending... catastrophy!)
> 
> They are all receiving data. Its a download-service. receive-buffer is set 
> to 24 KB and send-buffer set to 224 KB. I don't see a problem with 
> port-space. I only have 3500 sockets when the problem appears but it 
> appears suddenly.

I'm a bit confused, it is a download service so you are probably *sending*
data? 

> >But it would help if you looked at the stats and ifconfig
> >to see who's dropping packets, how many retransmissions there
> >are, memory failures, or the bottleneck is some other issue altogether...
> 
> No way. Doing 30000 packets per second and your stats are 32 bit integers ;)

So? You could be a bit more helpful. Sample over 5 seconds, you won't
overflow that.

Also, can you tcpdump a bit? Are you using iptables? The conntrack table
might be slowing you down. 

I have a hunch this problem has to do with high-mem issues though.

Good luck!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
