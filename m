From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] proc_fork_connector: a lockless ->real_parent
 usage is not safe
Date: Thu, 28 Jul 2011 18:27:05 -0700 (PDT)
Message-ID: <20110728.182705.1674417841277333408.davem@davemloft.net>
References: <201107282054.p6SKsPtJ007979@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oleg@redhat.com, johnpol@2ka.mipt.ru,
	vzapolskiy@gmail.com, zbr@ioremap.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384Ab1G2B1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 21:27:34 -0400
In-Reply-To: <201107282054.p6SKsPtJ007979@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 28 Jul 2011 13:54:25 -0700

> From: Oleg Nesterov <oleg@redhat.com>
> 
> proc_fork_connector() uses ->real_parent lockless.  This is not safe if
> copy_process() was called with CLONE_THREAD or CLONE_PARENT, in this case
> the parent != current can go away at any moment.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Zapolskiy <vzapolskiy@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Evgeniy Polyakov <zbr@ioremap.net>
> Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
