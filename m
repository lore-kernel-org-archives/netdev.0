From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: xilinx_emaclite: set protocol
 selector bits when writing ANAR
Date: Fri, 31 May 2013 17:26:54 -0700 (PDT)
Message-ID: <20130531.172654.1594446064482575081.davem@davemloft.net>
References: <1382011039.590745.1369866978593.open-xchange@email.1und1.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, monstr@monstr.eu
To: renner@efe-gmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab3FAA0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:26:55 -0400
In-Reply-To: <1382011039.590745.1369866978593.open-xchange@email.1und1.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Date: Thu, 30 May 2013 00:36:18 +0200 (CEST)

> This patch sets the protocol selector bits (4:0) of the PHY's MII_ADVERTISE
> register (ANAR) when writing ADVERTISE_ALL. The protocol selector bits are
> indicating IEEE 803.3u support and are fixed / read-only on some PHYs. Not
> setting them correctly on others (like TI DP83630) makes the PHY fall back
> to 10M HDX mode which should be avoided.
> 
> Tested for TI DP83630 PHY on Microblaze platform.
> 
> Signed-off-by: Jens Renner <renner@efe-gmbh.de>

This patch has been corrupted by your email client, among other things it
has corrupted the whitespace in the patch, changing TAB characters into
sequences of spaces.

Please read Documentation/email-clients.txt in the kernel sources, and then
send a test patch to yourself.  Do not resubmit this patch to the list until
you can successfully apply the test patch you email to yourself.

Thanks.
