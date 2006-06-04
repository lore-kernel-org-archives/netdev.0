From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 19:17:54 +0200
Message-ID: <200606041917.55496.oliver@neukum.org>
References: <44817083.508@gentoo.org> <200606040025.32275.oliver@neukum.org> <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Daniel Drake" <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.kontent.de ([81.88.34.36]:11935 "EHLO Mail1.KONTENT.De")
	by vger.kernel.org with ESMTP id S1750781AbWFDRRl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 13:17:41 -0400
To: "John Que" <qwejohn@gmail.com>
In-Reply-To: <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 4. Juni 2006 18:29 schrieb John Que:
> =A0 I had noticed that the zd1211 driver does call request_irq() in z=
d1205_open(),
> file zd1205.c; grepping for request_irq() in the rewrite driver yield=
s
> no results.
> (I looked at the rewrite version from a week ago but in this point it
> is probably the
> same).
> Why is this so ? I assume that the softmac layer does not call reques=
t_irq() on
> behalf of the driver because this is not supposed to be like it, as I=
 understand
> its functionality. Can anybody briefly calrify this point ?

A USB driver never will request an irq. Interrupt handling is done in
the core usb layer. Individual drivers have no business there.

	Regards
		Oliver
