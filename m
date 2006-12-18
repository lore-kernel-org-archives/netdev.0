From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] he: tiny space savings
Date: Sun, 17 Dec 2006 17:11:59 -0800 (PST)
Message-ID: <20061217.171159.32723537.davem@davemloft.net>
References: <20061217125622.GA4973@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, webmaster@programmierforen.de,
	kernel-janitors@lists.osdl.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49654
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753347AbWLRBL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:11:59 -0500
To: adobriyan@gmail.com
In-Reply-To: <20061217125622.GA4973@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 17 Dec 2006 15:56:22 +0300

> From: Andi Drebes <webmaster@programmierforen.de>
> 
>    text    data     bss     dec     hex filename
>   20015     480      28   20523    502b drivers/atm/he.o
>   19997     480      28   20505    5019 drivers/atm/he.o
> 
> Signed-off-by: Andi Drebes <webmaster@programmierforen.de>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

As Adrian said, this CVS string is totally useless.

That being said, it should be replaced with an
appropriate piece of versioning information, like
the ones we use via MODULE_VERSION() in other drivers.

I'll be happy to apply a patch which gets rid of the
CVS references, and replaces it with something useful.

Thanks.
