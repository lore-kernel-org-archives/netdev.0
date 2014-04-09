From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: take PMTU from tunnel UDP socket
Date: Wed, 09 Apr 2014 15:25:08 -0400 (EDT)
Message-ID: <20140409.152508.873221226779407639.davem@davemloft.net>
References: <20140409022320.752f036a@laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmgenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933705AbaDITZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 15:25:12 -0400
In-Reply-To: <20140409022320.752f036a@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Petukhov <dmgenp@gmail.com>
Date: Wed, 9 Apr 2014 02:23:20 +0600

> When l2tp driver tries to get PMTU for the tunnel destination, it uses
> the pointer to struct sock that represents PPPoX socket, while it
> should use the pointer that represents UDP socket of the tunnel.
> 
> Signed-off-by: Dmitry Petukhov <dmgenp@gmail.com>

Nice, 4 year old bug :-)

Applied and queued up for -stable, thanks.
