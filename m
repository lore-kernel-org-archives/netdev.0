From: John Heffner <jheffner@psc.edu>
Subject: Re: A case AGAINST checksum offload
Date: Fri, 12 Nov 2004 18:56:24 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0411121854220.8989@dexter.psc.edu>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
 <1100303625.14465.631.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1100303625.14465.631.camel@localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Nov 2004, Dave Hansen wrote:

> On Fri, 2004-11-12 at 15:46, John Heffner wrote:
> > Currently with many common Ethernet devices in Linux, hardware TCP
> > checksumming is enabled by default.  This seems fairly dangerous to me.
> > Most link layer checksums are much stronger than the TCP/UDP checksum;
> > most bit errors are caught by these.  However, one of the primary purposes
> > of the TCP/UDP checksum is to detect errors occurring outside the
> > protection of the link layer checksums -- errors when data is reassembled
> > or copied across busses inside hosts and routers.
>
> If you're getting errors copying things on buses inside of the machine,
> don't you have bigger problems than corrupt packets?  For instance, why
> doesn't your disk controller have the same problem?
>
> Just curious.

It's a probem with the NIC.  It did the same thing in a different machine.
The point is that I think it's a good idea to mitigate the effects of
faulty hardware, especially if you can do so nearly for free.

  -John
