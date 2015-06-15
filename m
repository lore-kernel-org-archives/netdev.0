From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Fwd: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as
 wwan
Date: Mon, 15 Jun 2015 11:08:58 +0200
Message-ID: <1434359338.1681.4.camel@suse.com>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl>
	 <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33832 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754282AbbFOJJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 05:09:59 -0400
In-Reply-To: <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-06-14 at 13:51 -1000, Linus Torvalds wrote:
> Hmm. Oliver is marked as the maintainer of the USB CDC code, but

I do CDC ACM, CDC WDM and CDC Ether, but not CDC NCM (it is a
very different beast)

> others have touched it more recently. So I'm just wildly adding peopl=
e
> to the cc to comment on this patch and maybe apply it.
> Oliver/David/Ben/Bj=C3=B8rn?

That said this patch looks very broad. There are devices this fits
which are legitimately WWAN. I would ask Huawei to come up
with a solution of finer granularity.

	HTH
		Oliver
