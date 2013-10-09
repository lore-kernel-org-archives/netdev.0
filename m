From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] gianfar: Enable eTSEC-20 erratum w/a for P2020 Rev1
Date: Wed, 09 Oct 2013 14:02:56 -0400 (EDT)
Message-ID: <20131009.140256.1615997457968740448.davem@davemloft.net>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
	<1381339242-32030-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab3JISC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 14:02:58 -0400
In-Reply-To: <1381339242-32030-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 9 Oct 2013 20:20:42 +0300

> Enable workaround for P2020/P2010 erratum eTSEC 20,
> "Excess delays when transmitting TOE=1 large frames".
> The impact is that frames lager than 2500-bytes for which
> TOE (i.e. TCP/IP hw accelerations like Tx csum) is enabled
> may see excess delay before start of transmission.
> This erratum was fixed in Rev 2.0.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
