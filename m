From: Johannes Stezenbach <js@linuxtv.org>
Subject: Re: 2.6.11: USB broken on nforce4, ipv6 still broken, centrino speedstep even more broken than in 2.6.10
Date: Tue, 22 Mar 2005 03:18:57 +0100
Message-ID: <20050322021857.GA17972@linuxtv.org>
References: <20050311202122.GA13205@fefe.de> <20050311173308.7a076e8f.akpm@osdl.org> <20050321163358.1b4968a0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: felix-linuxkernel@fefe.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050321163358.1b4968a0.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > 
> > (Added netdev cc)
> > 
> > Felix von Leitner <felix-linuxkernel@fefe.de> wrote:
> > >
> > > Now about IPv6: npush and npoll are two applications I wrote.  npush
> > > sends multicast announcements and opens a TCP socket.  npoll receives
> > > the multicast announcement and connects to the source IP/port/scope_id
> > > of the announcement.  If both are run on the same machine, npoll sees
> > > the link local address of eth0 as source IP, and the interface number of
> > > eth0 as scope_id.  So far so good.  Trying to connect() however hangs.
> > > Since this has been broken in different ways for as long as I can
> > > remember in Linux, and I keep complaining about it every half a year or
> > > so.  Can't someone fix this once and for all?  IPv4 checks whether we
> > > are connecting to our own address and reroutes through loopback, why
> > > can't IPv6?
> 
> afaik, this problem is still open.  If you have time, please provide
> additional info for the net developers.  Maybe the source to npoll anbd
> npush?

Grab the ncp package from http://www.fefe.de/ncp/, or more specifically
ftp://ftp.fu-berlin.de/unix/network/ncp/ncp-1.2.3.tar.bz2.

It's a very useful and handy tool for pushing around data within
a LAN of a small workgroup, one guy does "npush foo" and yells
at the intended recepient "do npoll". The first one to do
it wins and gets foo ;-)

Johannes
