From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Use a different default for each family
Date: Tue, 26 May 2009 20:54:58 -0700 (PDT)
Message-ID: <20090526.205458.222482251.davem@davemloft.net>
References: <200905261437.47495.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755792AbZE0Dy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:54:58 -0400
In-Reply-To: <200905261437.47495.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 26 May 2009 14:37:47 +0200

> The r8169 driver supports 3 different families of network chips
> (RTL8169, RTL8168 and RTL8101). When an unknown version is found, the
> driver currently always defaults to the RTL8169 variant. This has very
> little chance to ever work for chips of the other families. So better
> define a per-family default.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied to net-next-2.6, thanks.
