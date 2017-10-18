From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wanxl: use m68k-linux-gnu-as if available
Date: Wed, 18 Oct 2017 12:08:12 +0100 (WEST)
Message-ID: <20171018.120812.879877583327430024.davem@davemloft.net>
References: <20171012232434.15890-1-kilobyte@angband.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: kilobyte@angband.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751509AbdJRLIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:08:44 -0400
In-Reply-To: <20171012232434.15890-1-kilobyte@angband.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Borowski <kilobyte@angband.pl>
Date: Fri, 13 Oct 2017 01:24:34 +0200

> This fixes build failure on Debian based systems: GNU as is the only m68k
> assembler available in the archive (package binutils-m68k-linux-gnu).
> 
> Signed-off-by: Adam Borowski <kilobyte@angband.pl>

The Kconfig help text for the config option controlling the build
firmware is extremely clear what the requirements are for enabling
that option.

And that is: "It requires as68k, ld68k and hexdump programs."
