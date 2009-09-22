From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Set SKY2_HW_RAM_BUFFER in sky2_init
Date: Tue, 22 Sep 2009 14:21:54 -0700 (PDT)
Message-ID: <20090922.142154.152743400.davem@davemloft.net>
References: <4AB788F4.90503@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbZIVVVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:21:36 -0400
In-Reply-To: <4AB788F4.90503@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Mon, 21 Sep 2009 23:08:52 +0900

> The SKY2_HW_RAM_BUFFER bit in hw->flags was checked in sky2_mac_init(),
>  before being set later in sky2_up().
> 
> Setting SKY2_HW_RAM_BUFFER in sky2_init() where other hw->flags are set
>  should avoid this problem recurring.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Applied and queued up for -stable, thanks.
