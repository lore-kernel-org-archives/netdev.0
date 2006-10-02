From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Introduce BROKEN_ON_64BIT facility
Date: Mon, 02 Oct 2006 14:03:28 +0100
Message-ID: <1159794208.8907.9.camel@localhost.localdomain>
References: <20061002045512.GA8835@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>,
	chas@cmf.nrl.navy.mil, netdev@vger.kernel.org, kkeil@suse.de,
	kai.germaschewski@gmx.de, isdn4linux@listserv.isdn4linux.de,
	mac@melware.de, markus.lidel@shadowconnect.com, samuel@sortiz.org,
	Neela.Kolli@engenio.com, linux-scsi@vger.kernel.org,
	Greg KH <greg@kroah.com>, thomas@winischhofer.net, ak@suse.de
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061002045512.GA8835@havoc.gtf.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Llu, 2006-10-02 am 00:55 -0400, ysgrifennodd Jeff Garzik:
> Add a broken-on-64bit option, similar to the existing broken-on-smp
> config option.  This is just the first pass, marking the obvious
> candidates.

NAK. This contains lots of stuff whcih isn't broken in the first place.

(Eg Megaraid works with 32bit config tools not 64bit ones and is
otherwise fine, ISDN is just bogus warnings now swatted)

