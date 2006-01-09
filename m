From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] net: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Mon, 9 Jan 2006 09:31:08 -0200
Message-ID: <39e6f6c70601090331g3eaa4b0ge3b8102e94a7af65@mail.gmail.com>
References: <1136789216.6653.17.camel@spereira05.tusc.com.au>
	 <200601091054.35010.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: spereira@tusc.com.au, linux-kenel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@muc.de>,
	SP <pereira.shaun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751220AbWAILbL@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200601091054.35010.arnd@arndb.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/06, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 09 January 2006 06:46, Shaun Pereira wrote:

> > Since we are interested in ioctl's from userspace I have not added the
> > .compat_ioctl function pointer to struct net_device. The assumption
> > being once the userspace data has reached the kernel via the socket api,
> > if the socket layer protocol knows how to handle the data, it will
> > prepare it for the device.
>
> I think we need to have it in the long run, but if you don't need it
> for x25, then it's not your call to implement net_device->compat_ioctl.
> I've been thinking about how to get it right before, but did not
> reach a proper conclusion, since dev_ioctl is called in so many places
> that would all need to be changed for this.

Nowadays dev_ioctl is only called from one funcion: sock_ioctl in
net/socket.c, this is after a recent changeset by hch.

- Arnaldo
