From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net] ixp4xx_hss: fix build failure after logging conversion
Date: Mon, 10 Sep 2012 11:35:28 +0200
Message-ID: <15505259.4Zl8C80Fzd@flexo>
References: <1347266590-884-1-git-send-email-florian@openwrt.org> <1347267855.6069.2.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl,
	David Miller <davem@davemloft.net>, stable@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42426 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2IJJgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 05:36:08 -0400
In-Reply-To: <1347267855.6069.2.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 September 2012 02:04:15 Joe Perches wrote:
> On Mon, 2012-09-10 at 10:43 +0200, Florian Fainelli wrote:
> > Commit c75bb2c6f0cf455c23e60f14d780e841dd47f801 (ixp4xx_hss: Update to
> > current logging forms) converted the ixp4xx_hss module to use the current
> > logging macros, but forgot to include linux/module.h, leading to the
> > following build failures:
> 
> Bad explanation.
> This commit had nothing to do with any missing module.h.

You are right, this issue dates back from day one when this driver got merged, 
I will repost a v2 with the proper commit.
--
Florian
