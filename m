From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/33] sfc: Don't count RX checksum errors during
 loopback self-test
Date: Fri, 12 Dec 2008 21:42:50 -0800 (PST)
Message-ID: <20081212.214250.81561140.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125306.GM10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMFmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:42:49 -0500
In-Reply-To: <20081212125306.GM10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:53:07 +0000

> The loopback self-test checks that IP packets with incorrect checksums
> are not altered when sent on a queue with checksum generation off.
> These should not contribute to RX error statistics.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
