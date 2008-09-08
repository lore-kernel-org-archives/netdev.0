From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] warn: Turn the netdev timeout WARN_ON() into a WARN()
Date: Mon, 08 Sep 2008 16:18:05 -0700 (PDT)
Message-ID: <20080908.161805.198239001.davem@davemloft.net>
References: <20080907092804.12be0ae7@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbYIHXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 19:18:11 -0400
In-Reply-To: <20080907092804.12be0ae7@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 7 Sep 2008 09:28:04 -0700

> warn: Turn the netdev timeout WARN_ON() into a WARN()
> 
> this patch turns the netdev timeout WARN_ON_ONCE() into a WARN_ONCE(),
> so that the device and driver names are inside the warning message.
> This helps automated tools like kerneloops.org to collect the data
> and do statistics, as well as making it more likely that humans
> cut-n-paste the important message as part of a bugreport.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Applied, thanks.
