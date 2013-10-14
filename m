From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: [PATCH] net/ethernet: cpsw: Bugfix interrupts before enabling napi
Date: Mon, 14 Oct 2013 13:48:29 +0200
Message-ID: <8738o4rs36.fsf@dell.be.48ers.dk>
References: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37883 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab3JNLsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 07:48:32 -0400
Received: by mail-wi0-f179.google.com with SMTP id hm4so1700756wib.6
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 04:48:31 -0700 (PDT)
In-Reply-To: <1381691821-25498-1-git-send-email-mpa@pengutronix.de> (Markus
	Pargmann's message of "Sun, 13 Oct 2013 21:17:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Markus" == Markus Pargmann <mpa@pengutronix.de> writes:

 Markus> If interrupts happen before napi_enable was called, the driver will not
 Markus> work as expected. Network transmissions are impossible in this state.
 Markus> This bug can be reproduced easily by restarting the network interface in
 Markus> a loop. After some time any network transmissions on the network
 Markus> interface will fail.

 Markus> This patch fixes the bug by enabling napi before enabling the network
 Markus> interface interrupts.

 Markus> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
