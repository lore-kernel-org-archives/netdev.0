From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: kernel bug in socketpair()
Date: 23 Jul 2003 17:13:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058976818.5520.91.camel@dhcp22.swansea.linux.org.uk>
References: <200307231332.JAA26197@raptor.research.att.com>
	 <1058970007.5520.68.camel@dhcp22.swansea.linux.org.uk>
	 <20030723083621.26429e51.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dgk@research.att.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   gsf@research.att.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723083621.26429e51.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2003-07-23 at 16:36, David S. Miller wrote:
> > This is intentional - sockets do not have an "open" operation currently.
> 
> Sure, but we've known this for a long time.
> 
> And because we knew, we decided not to add an "open"
> method to sockets.  The reason, as I remember it, was
> security.
> 
> Was it not?

Mostly if I remember rightly that if you don't do the check because you have
no open operation to create a new instance you crash the box. HPA did have 
some sensible ideas about how to do "open" on AF_UNIX sockets but for the 
others its really unclear quite what "open" means
