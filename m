From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK 03/04]: Remove unnecessary locking in dump callbacks
Date: Mon, 16 Apr 2007 17:01:19 -0700 (PDT)
Message-ID: <20070416.170119.101870744.davem@davemloft.net>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
	<20070416074953.19262.13878.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754059AbXDQABR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 20:01:17 -0400
In-Reply-To: <20070416074953.19262.13878.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 09:51:55 +0200 (MEST)

> [RTNETLINK]: Remove unnecessary locking in dump callbacks
> 
> Since we're now holding the rtnl during the entire dump operation, we can
> remove additional locking for rtnl protected data. This patch does that
> for all simple cases (dev_base_lock for dev_base walking, RCU protection
> for FIB rule dumping).
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
