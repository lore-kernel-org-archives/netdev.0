From: David Brownell <david-b@pacbell.net>
Subject: Re: Broken rndis_host with #define DEBUG (by a475f603d23392f386e45cf377b17c30ed3bbb80)
Date: Sat, 12 Jun 2010 19:49:27 -0700 (PDT)
Message-ID: <299618.58880.qm@web180304.mail.gq1.yahoo.com>
References: <1276377038.21640.67.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n5-vm0.bullet.mail.gq1.yahoo.com ([67.195.8.62]:43661 "HELO
	n5-vm0.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752897Ab0FMCt2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jun 2010 22:49:28 -0400
In-Reply-To: <1276377038.21640.67.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Sat, 6/12/10, Joe Perches <joe@perches.com> wrote:

> > rndis_host oopses with #define DEBUG, in
> generic_rndis_bind() when=A0=20
> > calling netif_dbg(). Problem is that
> (netdev)->dev.parent is NULL

> > (used in netdev_printk) while generic_rndis_bind is
> called.Thanks.

Should have been assigned by SET_NETDEV_DEV()
in usbnet_probe() ... before calling the
bind() routine


Maybe just moving that SET_NETDEV_DEV earlier
would suffice.


>=20


