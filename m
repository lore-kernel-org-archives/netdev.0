From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix ipv6 neighbour unregister_sysctl_table warning
Date: Mon, 31 Jan 2011 20:55:05 -0800 (PST)
Message-ID: <20110131.205505.183064142.davem@davemloft.net>
References: <m11v3utagp.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753815Ab1BAEya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:54:30 -0500
In-Reply-To: <m11v3utagp.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 30 Jan 2011 12:15:02 -0800

> 
> In my testing of 2.6.37 I was occassionally getting a warning about
> sysctl table entries being unregistered in the wrong order.  Digging
> in it turns out this dates back to the last great sysctl reorg done
> where Al Viro introduced the requirement that sysctl directories
> needed to be created before and destroyed after the files in them.
> 
> It turns out that in that great reorg /proc/sys/net/ipv6/neigh was
> overlooked.  So this patch fixes that oversight and makes an annoying
> warning message go away.
> 
>>------------[ cut here ]------------
>>WARNING: at kernel/sysctl.c:1992 unregister_sysctl_table+0x134/0x164()
>>Pid: 23951, comm: kworker/u:3 Not tainted 2.6.37-350888.2010AroraKernelBeta.fc14.x86_64 #1
>>Call Trace:
 ...
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied and queued for -stable, thanks a lot Eric.
