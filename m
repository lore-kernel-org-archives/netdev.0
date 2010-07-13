From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: use interrupt for MDIO completion indication
Date: Mon, 12 Jul 2010 20:36:11 -0700 (PDT)
Message-ID: <20100712.203611.67894902.davem@davemloft.net>
References: <006416d38a8e51ba8dd8631613a991528dc7976a.1278918594.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, bryan.wu@canonical.com, gerg@uclinux.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753909Ab0GMDf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:35:56 -0400
In-Reply-To: <006416d38a8e51ba8dd8631613a991528dc7976a.1278918594.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Mon, 12 Jul 2010 10:12:51 +0300

> With the move to phylib (commit e6b043d) I was seeing sporadic "MDIO write
> timeout" messages. Measure of the actual time spent showed latency times of
> more than 1600us.
> 
> This patch uses the MII event indication of the FEC hardware to detect
> completion of MDIO transactions.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied.
