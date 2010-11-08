From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Detect and ignore netif_stop_queue() calls
 before register_netdev()
Date: Mon, 08 Nov 2010 12:19:37 -0800 (PST)
Message-ID: <20101108.121937.183055720.davem@davemloft.net>
References: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
	<1289061572-5029-2-git-send-email-guichaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guichaz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754440Ab0KHUTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:19:13 -0500
In-Reply-To: <1289061572-5029-2-git-send-email-guichaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Chazarain <guichaz@gmail.com>
Date: Sat,  6 Nov 2010 17:39:32 +0100

> After e6484930d7c73d324bccda7d43d131088da697b9: net: allocate tx queues in register_netdevice
> These calls make net drivers oops at load time, so let's avoid people
> git-bisect'ing known problems.
> 
> Signed-off-by: Guillaume Chazarain <guichaz@gmail.com>

Applied, but I'd like to remove this check after we've had some
time to weed out all of the offending cases, since this sits
in a hot path of sorts.

Thanks.
