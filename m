From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: O_DIRECT sockets? (was [RESEND] tuning linux for high network
 performance?)
Date: Wed, 23 Oct 2002 09:34:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6CF9E.327E165F@us.ibm.com>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <3DB6B96F.A0DE47BF@us.ibm.com> <200210231726.21135.roy@karlsbakk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roy Sigurd Karlsbakk wrote:

> I'm doing O_DIRECT read (from disk), so it needs to be user -> kernel, then.
> 
> any chance of using O_DIRECT to the socket?

Hmm, I'm still not clear on why you cannot use sendfile()?
I was not aware of any upper limit to the file size in order
for sendfile() to be used?  From what little I know, this 
is exactly the kind of situation that sendfile was intended
to benefit. 

thanks,
Nivedita
