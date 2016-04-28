From: David Miller <davem@davemloft.net>
Subject: Re: myri10ge: fix sleeping with bh disabled
Date: Thu, 28 Apr 2016 14:21:42 -0400 (EDT)
Message-ID: <20160428.142142.1324480837935590925.davem@davemloft.net>
References: <20160425085918.GB2608@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hykim@myri.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcD1SVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 14:21:49 -0400
In-Reply-To: <20160425085918.GB2608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Mon, 25 Apr 2016 10:59:19 +0200

> napi_disable() can not be called with bh disabled, move locking just
> around myri10ge_ss_lock_napi() .
> 
> Patches fixes following bug:
> 
> [  114.278378] BUG: sleeping function called from invalid context at net/core/dev.c:4383 
> <snip>
> [  114.313712] Call Trace: 
> [  114.314943]  [<ffffffff817010ce>] dump_stack+0x19/0x1b 
> [  114.317673]  [<ffffffff810ce7f3>] __might_sleep+0x173/0x230 
> [  114.320566]  [<ffffffff815b3117>] napi_disable+0x27/0x90 
> [  114.323254]  [<ffffffffa01e437f>] myri10ge_close+0xbf/0x3f0 [myri10ge] 
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Applied.
