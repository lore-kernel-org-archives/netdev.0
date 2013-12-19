From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 12:05:49 -0800
Message-ID: <1387483549.19078.373.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131219193231.GB14612@netboy>
	 <1387483439.19078.372.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:62886 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3LSUFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:05:51 -0500
Received: by mail-pa0-f50.google.com with SMTP id kl14so1632256pab.9
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 12:05:50 -0800 (PST)
In-Reply-To: <1387483439.19078.372.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 12:03 -0800, Eric Dumazet wrote:

> While looking at another driver, founding the same issue.

( drivers/net/ethernet/arc/emac_main.c )
