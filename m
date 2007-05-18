From: Mariusz =?iso-8859-2?q?Koz=B3owski?= <m.kozlowski@tuxland.pl>
Subject: Re: [git patches] net driver updates
Date: Fri, 18 May 2007 23:46:21 +0200
Message-ID: <200705182346.21835.m.kozlowski@tuxland.pl>
References: <20070508063337.GA12474@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:1462 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754078AbXERVxU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 17:53:20 -0400
In-Reply-To: <20070508063337.GA12474@havoc.gtf.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,=20

> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 7053026..111f23d 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -279,6 +279,40 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)

=2E..

> +#define SMC_outb(v, a, r) =A0 =A0 =A0outw(((inw((a)+((r)&~1))*(0xff<=
<8*(r%2)))) | ((v)<<(8*(r&2)))), (a) + ((r)&~1))

This one has unbalanced parenthesis.

Regards,

	Mariusz
