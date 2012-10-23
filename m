From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/4] net/macb: fix truncate warnings
Date: Tue, 23 Oct 2012 09:21:11 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B705B@saturn3.aculab.com>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com> <1350931534-8416-2-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: "Joachim Eastwood" <manabian@gmail.com>, <nicolas.ferre@atmel.com>,
	<davem@davemloft.net>, <hskinnemoen@gmail.com>,
	<egtvedt@samfundet.no>, <plagnioj@jcrosoft.com>,
	<bgat@billgatliff.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45550 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753450Ab2JWIdF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 04:33:05 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12420-02 for <netdev@vger.kernel.org>;
 Tue, 23 Oct 2012 09:33:00 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1350931534-8416-2-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When building macb on x86_64 the following warnings show up:
>   drivers/net/ethernet/cadence/macb.c: In function macb_interrupt:
>   drivers/net/ethernet/cadence/macb.c:556:4: warning: large integer implicitly truncated to unsigned type [-Woverflow]
...
> -			macb_writel(bp, IDR, ~0UL);
> +			macb_writel(bp, IDR, -1);

Seems wrong to fix an error with an unsigned value
by using -1.

	David
