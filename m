From: "David S. Miller" <davem@rth.ninka.net>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: 23 Oct 2002 21:11:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035432669.9628.1.camel@rth.ninka.net>
References: <200210231218.18733.roy@karlsbakk.net>
	<20021023130101.GA646@outpost.ds9a.nl>
	<1035379308.5950.3.camel@rth.ninka.net>
	<200210231542.48673.roy@karlsbakk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
   Kernel mailing list
	 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
In-Reply-To: <200210231542.48673.roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2002-10-23 at 06:42, Roy Sigurd Karlsbakk wrote:
> As far as I've understood, sendfile() won't do much good with large files. Is 
> this right?

There is always a benefit to using sendfile(), when you use
sendfile() the cpu doesn't touch one byte of the data if
the network card support TX checksumming.  The disk DMAs
to ram, then the net card DMAs from ram.  Simple as that.
