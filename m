From: David Dillow <dave@thedillows.org>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: 07 Jun 2004 09:52:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086616346.4903.12.camel@ori.thedillows.org>
References: <20040606165322.GA13247@k3.hellgate.ch>
	 <1086575392.4731.9.camel@ori.thedillows.org>
	 <20040607114832.GA32569@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040607114832.GA32569@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-06-07 at 07:48, Roger Luethi wrote:
> On Sun, 06 Jun 2004 22:29:52 -0400, David Dillow wrote:
> > I think typhoon's OK -- I calculate the filter on the host, and then do
> > a cpu_to_le32() on the final values, since the processor on the NIC is
> > in little-endian mode.
> > 
> > However, I've never tested it. I'll be happy to do so, if someone will
> > point me to appropriate code -- I've got an Ultra5 as well, so I can
> > test both big and little endian machines. Otherwise, I'll test it when I
> > get around to writing something, or someone reports a bug. :)
> 
> Warning: This is a very basic functionality test using standard Linux
> tools. Some existing multicast problems are detected by this (if you
> screw up the endianness of the filter hash, you will know :-)). Others
> are not.

Thanks for the info; it seems typhoon may have some problems -- I see
the 224.1.1.1 packets before I join the group, so I'll need to see
what's up. I'll check big endian tonight, if possible.

Dave
