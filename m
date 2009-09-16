From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix qdisc_create on stab error handling
Date: Tue, 15 Sep 2009 23:42:22 -0700 (PDT)
Message-ID: <20090915.234222.32365432.davem@davemloft.net>
References: <20090915184651.GA8373@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750857AbZIPGmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 02:42:06 -0400
In-Reply-To: <20090915184651.GA8373@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 15 Sep 2009 20:46:51 +0200

> If qdisc_get_stab returns error in qdisc_create there is skipped qdisc
> ops->destroy, which is necessary because it's after ops->init at the
> moment, so memory leaks are quite probable.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot!
