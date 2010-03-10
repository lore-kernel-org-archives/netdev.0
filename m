From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: fix setting mac address for AX88772
Date: Wed, 10 Mar 2010 07:34:07 -0800 (PST)
Message-ID: <20100310.073407.104676652.davem@davemloft.net>
References: <20100309222438.10684.46211.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhollis@davehollis.com
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756755Ab0CJPdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:33:47 -0500
In-Reply-To: <20100309222438.10684.46211.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Wed, 10 Mar 2010 00:24:38 +0200

> Setting new MAC address only worked when device was set to promiscuous mode.
> Fix MAC address by writing new address to device using undocumented command
> AX_CMD_READ_NODE_ID+1. Patch is tested with AX88772 device.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied.
