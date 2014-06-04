From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net: fec: Enable Software TSO to improve the tx
 performance
Date: Wed, 04 Jun 2014 15:28:50 -0700 (PDT)
Message-ID: <20140604.152850.1591854206282161278.davem@davemloft.net>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.guo@linaro.org, R49496@freescale.com,
	ezequiel.garcia@free-electrons.com, bhutchings@solarflare.com,
	stephen@networkplumber.org, b20596@freescale.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaFDW2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:28:52 -0400
In-Reply-To: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think you need to start taking David Laight's feedback more seriously.

He's right, it makes no sense at all the increase the number of RX
descriptors for the sake of a send side feature like TSO.

If you have a another reason to increase the RX descriptor count, do
it as a separate change and with an appropriate commit log message
explaining WHY you are doing this.

I'm not applying this patch series until you start taking the feedback
you are receiving to heart.
