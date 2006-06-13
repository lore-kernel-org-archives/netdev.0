From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 05:22:15 -0600
Message-ID: <20060613052215.B27858@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751052AbWFMLW3@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060613140716.6af45bec@localhost.localdomain>; from shemminger@osdl.org on Tue, Jun 13, 2006 at 02:07:16PM +0900
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

On Tue, 13 Jun 2006, Stephen Hemminger wrote:

> > @@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
> >  EXPORT_SYMBOL(sockfd_lookup);
> >  EXPORT_SYMBOL(kernel_sendmsg);
> >  EXPORT_SYMBOL(kernel_recvmsg);
> > +EXPORT_SYMBOL(kernel_bind);
> > +EXPORT_SYMBOL(kernel_listen);
> > +EXPORT_SYMBOL(kernel_accept);
> > +EXPORT_SYMBOL(kernel_connect);
> > +EXPORT_SYMBOL(kernel_getsockname);
> > +EXPORT_SYMBOL(kernel_getpeername);
> > +EXPORT_SYMBOL(kernel_getsockopt);
> > +EXPORT_SYMBOL(kernel_setsockopt);
> > +EXPORT_SYMBOL(kernel_sendpage);
> > +EXPORT_SYMBOL(kernel_ioctl);
> 
> Don't we want to restrict this to GPL code with EXPORT_SYMBOL_GPL?

There are direct derivatives of the BSD/POSIX system call
interface.  The protocol function pointers within the socket
structure are not GPL only.  Why make this wrappered access to
them GPL only?  It will only encourange the reverse of what they
were intended to do: be used instead of the protocol function
pointers within the socket structure, that currently carry no
such restriction.
