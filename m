From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 02:59:43 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com>
References: <419C4E72.5050307@blueyonder.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
In-Reply-To: <419C4E72.5050307@blueyonder.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Ross Kendall Axe wrote:

> That seems eminently sensible. Again, I was just cut-n'-pasting from
> SOCK_STREAM. If these error codes are wrong, then SOCK_STREAM also needs
> fixing.

An issue here though is that what impact will this have on existing 
applications?

> > 
> > There is a non SELinux-related bug lurking in this code.
> 
> IMHO, there never was an SELinux bug here. SELinux merely exposed an 
> existing bug.

Looks like it, testing a fix now.

> I'm unable to reproduce that, or the bug you mention in your other 
> message. Care to send us your code?

See http://people.redhat.com/jmorris/net/seqpacket-killer-jm.tar.bz2 

> I think that af_unix.c needs a bit of cleaning up. All of the functions 
> are named as being stream vs dgram, even when the issue is connectionless 
> vs connection-oriented.

Agreed.


- James
-- 
James Morris
<jmorris@redhat.com>
