From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Transmit time stamping on tun/tap
 interfaces
Date: Mon, 22 Jul 2013 14:59:11 -0700 (PDT)
Message-ID: <20130722.145911.724108881981471003.davem@davemloft.net>
References: <cover.1374254757.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388Ab3GVV7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:59:12 -0400
In-Reply-To: <cover.1374254757.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 19 Jul 2013 19:40:08 +0200

> This series adds transmit SO_TIMESTAMPING for tun and tap devices.
> Having this support is useful for testing multiple instances of PTP
> programs (for example, to exercise the best master clock behavior)
> and for synchronizing virtual guests.
> 
> The first patch refactors the code that delivers raw error queue
> packets into a common function, in order to avoid multiple, nearly
> identical implementations. This can be used whenever a network layer
> has an error queue for transmit time stamp reporting only.

Series applied, thanks.

Next time, please use an appropriate subject prefix for patch #1.
For example, I added "net: " when I applied that patch.
