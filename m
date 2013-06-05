From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix bridged GSO for 57710/57711 chips
Date: Tue, 04 Jun 2013 17:17:37 -0700 (PDT)
Message-ID: <20130604.171737.311428267471179268.davem@davemloft.net>
References: <1370264397-27324-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab3FEARi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:17:38 -0400
In-Reply-To: <1370264397-27324-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 3 Jun 2013 15:59:57 +0300

> It was recently found out that GSO on 57710/57711 was broken, due to packets
> being sent without a valid IP checksum. 
> 
> Commit 057cf65 "bnx2x: Fix GSO for 57710/57711 chips" partially fixed this
> issue, but failed to set the correct IP checksum when receiving GSO packets
> via bridges, as such packets enter bnx2x_tx_split() and the FW flags needed
> to calculate IP checksum were erroneously set in the incorrect
> buffer descriptor.
> 
> This patch re-enables GSO in said scenario for 57710/57711 chips.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
