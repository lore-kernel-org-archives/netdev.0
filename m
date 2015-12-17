From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: clear ring delayed kick counters
Date: Thu, 17 Dec 2015 15:27:55 -0500 (EST)
Message-ID: <20151217.152755.253045949715481475.davem@davemloft.net>
References: <1450292932-24393-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043AbbLQU14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:27:56 -0500
In-Reply-To: <1450292932-24393-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 16 Dec 2015 19:08:52 +0000

> We need to clear delayed kick counters when we free rings otherwise
> after ndo_close()/ndo_open() we could kick HW by more entries than
> actually written to rings.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>

Applied, thank you.
