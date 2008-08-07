From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Add (struct sock*) sk parameter for send_ack()
Date: Wed, 06 Aug 2008 20:20:38 -0700 (PDT)
Message-ID: <20080806.202038.93643856.davem@davemloft.net>
References: <48981BDE.70201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753548AbYHGDUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 23:20:38 -0400
In-Reply-To: <48981BDE.70201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Tue, 05 Aug 2008 17:22:38 +0800

> Add (struct sock*) sk parameter for send_ack.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

This patch by itself breaks the build.

Don't submit patches this way.  Every patch applied should
still leave the tree building.

Also, since your OOPS and detailed description only exists
in the "0/3" email, it won't make it into the commit log
history where it belongs.

Considering all of this, I'd say you should fix this as
one big patch with a really nice commit log message.

Thanks.
