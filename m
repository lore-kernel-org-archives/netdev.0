From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Sat, 5 Oct 2002 09:27:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021004232715.GC3030@sourcefrog.net>
References: <Mutt.LNX.4.44.0210050053000.21202-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0210050053000.21202-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On  5 Oct 2002, James Morris <jmorris@intercode.com.au> wrote:
> Martin,
> 
> I'm not able to reproduce the bug exactly as described.  What kind of
> network connection were you using between the boxes, and what was the
> kernel version at the server end?

I was using VMware over 100Mbps to a 2.4.19 server.  I am pretty sure
it could also be reproduced over localhost TCP just in 2.2.21 inside
VMware.  I don't remember the exact hardware; I can let you know later.

It seems to not happen every time, but at least one time in three.

--
Martin
