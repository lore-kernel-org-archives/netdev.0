From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s6gmac: remove driver
Date: Sun, 19 Oct 2014 12:45:42 -0400 (EDT)
Message-ID: <20141019.124542.141206969262552652.davem@davemloft.net>
References: <1413672385-8492-1-git-send-email-dg@emlix.com>
	<1413672545-8535-1-git-send-email-dg@emlix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dg@emlix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbaJSQpo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 12:45:44 -0400
In-Reply-To: <1413672545-8535-1-git-send-email-dg@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Gl=F6ckner <dg@emlix.com>
Date: Sun, 19 Oct 2014 00:49:05 +0200

> The s6000 Xtensa support is removed from the kernel. There are no
> other chips using this driver.

That's not what I see in Linus's current tree:

[davem@localhost linux]$ git grep XTENSA_VARIANT_S6000
arch/xtensa/Kconfig:config XTENSA_VARIANT_S6000
arch/xtensa/Kconfig:	default "s6000"				if XTENSA_VARIANT_S6000
