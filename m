From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 08:36:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723083621.26429e51.davem@redhat.com>
References: <200307231332.JAA26197@raptor.research.att.com>
	<1058970007.5520.68.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dgk@research.att.com, linux-kernel@vger.kernel.org, gsf@research.att.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1058970007.5520.68.camel@dhcp22.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 Jul 2003 15:20:08 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Mer, 2003-07-23 at 14:32, David Korn wrote:
> > The first problem is that files created with socketpair() are not accessible
> > via /dev/fd/n or /proc/$$/fd/n where n is the file descriptor returned
> > by socketpair().  Note that this is not a problem with pipe().
> 
> This is intentional - sockets do not have an "open" operation currently.

Sure, but we've known this for a long time.

And because we knew, we decided not to add an "open"
method to sockets.  The reason, as I remember it, was
security.

Was it not?
