From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-usb-devel] [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Tue, 31 Oct 2006 10:40:15 -0700
Message-ID: <200610310940.16619.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610281410.13679.david-b@pacbell.net> <20061028213918.GE27968@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Randy Dunlap <randy.dunlap@oracle.com>, akpm@osdl.org,
	zippel@linux-m68k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, link@miggy.org,
	Christoph Hellwig <hch@infradead.org>, torvalds@osdl.org,
	greg@kroah.com, toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.mud.yahoo.com ([68.142.198.208]:9065 "HELO
	smtp109.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1423609AbWJaRmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 12:42:53 -0500
To: linux-usb-devel@lists.sourceforge.net
In-Reply-To: <20061028213918.GE27968@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > +#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
> > +#define HAVE_MII
> >...
> 
> This seems to cause a CONFIG_USB_USBNET=y, CONFIG_MII=m breakage
> (as already described earlier in this thread)?

Well, "alluded to" not described.  Fixable by the equivalent of

	config USB_USBNET
		...
		depends on MII if MII != n

except that Kconfig doesn't comprehend conditionals like that.


