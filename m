From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.11: USB broken on nforce4, ipv6 still broken, centrino
 speedstep even more broken than in 2.6.10
Date: Fri, 11 Mar 2005 17:33:08 -0800
Message-ID: <20050311173308.7a076e8f.akpm@osdl.org>
References: <20050311202122.GA13205@fefe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Felix von Leitner <felix-linuxkernel@fefe.de>
In-Reply-To: <20050311202122.GA13205@fefe.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(Added netdev cc)

Felix von Leitner <felix-linuxkernel@fefe.de> wrote:
>
> Now about IPv6: npush and npoll are two applications I wrote.  npush
> sends multicast announcements and opens a TCP socket.  npoll receives
> the multicast announcement and connects to the source IP/port/scope_id
> of the announcement.  If both are run on the same machine, npoll sees
> the link local address of eth0 as source IP, and the interface number of
> eth0 as scope_id.  So far so good.  Trying to connect() however hangs.
> Since this has been broken in different ways for as long as I can
> remember in Linux, and I keep complaining about it every half a year or
> so.  Can't someone fix this once and for all?  IPv4 checks whether we
> are connecting to our own address and reroutes through loopback, why
> can't IPv6?
> 
