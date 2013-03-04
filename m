From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] rds: limit the size allocated by
 rds_message_alloc()
Date: Mon, 04 Mar 2013 14:14:42 -0500 (EST)
Message-ID: <20130304.141442.2136706050807177427.davem@davemloft.net>
References: <1362363491-24501-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com, davej@redhat.com,
	venkat.x.venkatsubra@oracle.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab3CDTOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:14:45 -0500
In-Reply-To: <1362363491-24501-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  4 Mar 2013 10:18:11 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Dave Jones reported the following bug:
> 
> "When fed mangled socket data, rds will trust what userspace gives it,
> and tries to allocate enormous amounts of memory larger than what
> kmalloc can satisfy."
 ...
> Reported-by: Dave Jones <davej@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied and queued up for -stable, thanks.
