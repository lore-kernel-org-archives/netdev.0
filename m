From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: move zd1201 where it belongs
Date: Mon, 5 Jun 2006 10:13:29 -0400
Message-ID: <20060605141322.GB23350@tuxdriver.com>
References: <20060605103952.GA1670@elf.ucw.cz> <1149506120.3111.52.camel@laptopd505.fenrus.org> <20060605113332.GB2132@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Jirka Lenost Benc <jbenc@suse.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, pe1rxq@amsat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:16389 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751122AbWFEOUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 10:20:18 -0400
To: Pavel Machek <pavel@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060605113332.GB2132@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 01:33:33PM +0200, Pavel Machek wrote:
> On Po 05-06-06 13:15:20, Arjan van de Ven wrote:
> > On Mon, 2006-06-05 at 12:39 +0200, Pavel Machek wrote:
> > > zd1201 is wifi adapter, yet it is hiding in drivers/usb/net where
> > > noone can find it. This moves Kconfig/Makefile to right place; you
> > > still need to manually move .c and .h files.

> > do you think it should at least depend in some form or another on
> > CONFIG_USB ?
> 
> Right, added USB && to depends directive.

Did you mean to only copy Jiri and LKML?

It seems like you should have sent at least sent this to
netdev@vger.kernel.org, if not also to me, Jeroen Vreeken and/or
possibly Greg K-H (USB subsystem).

Will you be posting a new version, with the CONFIG_USB change?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
