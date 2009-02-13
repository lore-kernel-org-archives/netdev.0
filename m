From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] qlge: bugfix: Add missing dev_kfree_skb_any() call.
Date: Thu, 12 Feb 2009 16:39:06 -0800 (PST)
Message-ID: <20090212.163906.176568213.davem@davemloft.net>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
	<1234360717-32194-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755117AbZBMAjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:39:12 -0500
In-Reply-To: <1234360717-32194-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 11 Feb 2009 05:58:34 -0800

> We put the skb back if we can't get mapping for it.  We don't
> want unmapped buffers on our receive buffer queue.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
