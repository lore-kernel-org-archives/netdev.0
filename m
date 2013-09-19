From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Thu, 19 Sep 2013 08:57:23 +0200
Message-ID: <1379573843.8608.7.camel@linux-fkkt.site>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	 <878uyu6xjm.fsf@nemi.mork.no>
	 <CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	 <87zjra5dpx.fsf@nemi.mork.no> <1379523984.2430.3.camel@linux-fkkt.site>
	 <be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42863 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab3ISG51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 02:57:27 -0400
In-Reply-To: <be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-18 at 20:56 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> wrote:

> >No, USB 3.0 uses no companion controllers, so you can have devices
> >of any speed connected to it.
> >
>=20
> Ah, right. I don't own such modern hardware, but I should have known =
this anyway.=20
>=20
> This still doesn't change the fact that the driver is brand new for b=
rand new devices. I believe we should assume such devices will support =
ZLPs unless we have documentation stating anything else.

=46or such devices we might assume it. But how does that matter for
generic code? As any kind of device may be connected to XHCI, the sg
code is relevant for every driver. And I certainly don't want trouble
for older devices' drivers converted to sg.

	Regards
		Oliver
