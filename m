From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] ixp4xx_hss: fix build failure after logging
 conversion
Date: Mon, 10 Sep 2012 02:04:15 -0700
Message-ID: <1347267855.6069.2.camel@joe2Laptop>
References: <1347266590-884-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl,
	David Miller <davem@davemloft.net>, stable@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42651 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756801Ab2IJJER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 05:04:17 -0400
In-Reply-To: <1347266590-884-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 10:43 +0200, Florian Fainelli wrote:
> Commit c75bb2c6f0cf455c23e60f14d780e841dd47f801 (ixp4xx_hss: Update to
> current logging forms) converted the ixp4xx_hss module to use the current
> logging macros, but forgot to include linux/module.h, leading to the
> following build failures:

Bad explanation.
This commit had nothing to do with any missing module.h.
