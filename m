From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Thu, 24 Oct 2002 02:37:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021024023751.A26024@synapse.neuralscape.com>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <1035379308.5950.3.camel@rth.ninka.net> <200210231542.48673.roy@karlsbakk.net> <1035432669.9628.1.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@rth.ninka.net>
Content-Disposition: inline
In-Reply-To: <1035432669.9628.1.camel@rth.ninka.net>; from davem@rth.ninka.net on Wed, Oct 23, 2002 at 09:11:09PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 23, 2002 at 09:11:09PM -0700, David S. Miller wrote:
> On Wed, 2002-10-23 at 06:42, Roy Sigurd Karlsbakk wrote:
> > As far as I've understood, sendfile() won't do much good with large files. Is 
> > this right?
> 
> There is always a benefit to using sendfile(), when you use
> sendfile() the cpu doesn't touch one byte of the data if
> the network card support TX checksumming.  The disk DMAs
> to ram, then the net card DMAs from ram.  Simple as that.

Referring to:

$ rpm -qf /usr/include/sys/sendfile.h
glibc-devel-2.2.5-40

quoting "sendfile.h"

#ifdef __USE_FILE_OFFSET64
# error "<sys/sendfile.h> cannot be used with _FILE_OFFSET_BITS=64"
#endif

So, how does one use sendfile() for large files that are greater than 2
GBytes? Am I missing something?

Thanks,
Karen
-- 
 Karen Shaeffer
 Neuralscape; Santa Cruz, Ca. 95060
 shaeffer@neuralscape.com  http://www.neuralscape.com
