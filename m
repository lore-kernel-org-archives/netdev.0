From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: A case AGAINST checksum offload
Date: Fri, 12 Nov 2004 15:53:45 -0800
Message-ID: <1100303625.14465.631.camel@localhost>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-11-12 at 15:46, John Heffner wrote:
> Currently with many common Ethernet devices in Linux, hardware TCP
> checksumming is enabled by default.  This seems fairly dangerous to me.
> Most link layer checksums are much stronger than the TCP/UDP checksum;
> most bit errors are caught by these.  However, one of the primary purposes
> of the TCP/UDP checksum is to detect errors occurring outside the
> protection of the link layer checksums -- errors when data is reassembled
> or copied across busses inside hosts and routers.

If you're getting errors copying things on buses inside of the machine,
don't you have bigger problems than corrupt packets?  For instance, why
doesn't your disk controller have the same problem?

Just curious.

-- Dave
