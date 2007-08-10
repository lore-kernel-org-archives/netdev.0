From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/28] fix theoretical ccids_{read,write}_lock() race
Date: Fri, 10 Aug 2007 15:21:29 -0700 (PDT)
Message-ID: <20070810.152129.11385166.davem@davemloft.net>
References: <200708102111.l7ALBteq009403@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oleg@tv-sign.ru, acme@redhat.com,
	mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756789AbXHJWVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:21:32 -0400
In-Reply-To: <200708102111.l7ALBteq009403@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:55 -0700

> From: Oleg Nesterov <oleg@tv-sign.ru>
> 
> Make sure that spin_unlock_wait() is properly ordered wrt atomic_inc().
> 
> (akpm: can't we convert this code to use rwlocks?)
> 
> Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks!
