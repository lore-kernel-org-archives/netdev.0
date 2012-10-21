From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net/cadence: get rid of HAVE_NET_MACB
Date: Sun, 21 Oct 2012 19:27:07 -0400 (EDT)
Message-ID: <20121021.192707.1747557282711878897.davem@davemloft.net>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-2-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, hskinnemoen@gmail.com,
	egtvedt@samfundet.no, plagnioj@jcrosoft.com, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225Ab2JUX1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 19:27:09 -0400
In-Reply-To: <1350829392-3812-2-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You do know that this is going to generate warnings on 64-bit
platforms?

I was hoping you would have noticed and corrected this before
enabling the driver everywhere, I guess my expectations were
way too high :-/
