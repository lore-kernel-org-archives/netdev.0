From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: silence log messages for locally generated
 multicast
Date: Tue, 09 Dec 2008 15:48:45 -0800 (PST)
Message-ID: <20081209.154845.195219989.davem@davemloft.net>
References: <20081208122557.GB4498@alaris.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jsembera@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753522AbYLIXso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 18:48:44 -0500
In-Reply-To: <20081208122557.GB4498@alaris.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Sembera <jsembera@suse.cz>
Date: Mon, 8 Dec 2008 13:25:57 +0100

> This patch fixes minor annoyance during transmission of unsolicited
> neighbor advertisements from userspace to multicast addresses (as
> far as I can see in RFC, this is allowed and the similar functionality
> for IPv4 has been in arping for a long time).
> 
> Outgoing multicast packets get reinserted into local processing as if they
> are received from the network. The machine thus sees its own NA and fills
> the logs with error messages. This patch removes the message if NA has been
> generated locally.
> 
> Signed-off-by: Jan Sembera <jsembera@suse.cz>

Patch applied, thanks Jan.
