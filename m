From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] bridge: respect RFC2863 operational state
Date: Sun, 30 Dec 2012 02:32:37 -0800 (PST)
Message-ID: <20121230.023237.824657555139331896.davem@davemloft.net>
References: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
	<20121228.152754.707370216340290808.davem@davemloft.net>
	<20121228201522.62a48370@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2L3Kci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 05:32:38 -0500
In-Reply-To: <20121228201522.62a48370@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 28 Dec 2012 20:15:22 -0800

> The bridge link detection should follow the operational state
> of the lower device, rather than the carrier bit. This allows devices
> like tunnels that are controlled by userspace control plane to work
> with bridge STP link management.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
