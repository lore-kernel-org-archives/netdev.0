From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk while
 enabled auth
Date: Tue, 05 Feb 2008 03:02:39 -0800 (PST)
Message-ID: <20080205.030239.19240607.davem@davemloft.net>
References: <4794C51B.8040904@cn.fujitsu.com>
	<479A112D.5020201@hp.com>
	<47A81C72.8050207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	lksctp-developers@lists.sourceforge.net
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756299AbYBELCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:02:11 -0500
In-Reply-To: <47A81C72.8050207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 05 Feb 2008 17:21:06 +0900

> If STCP is started while /proc/sys/net/sctp/auth_enable is set 0 and 
> association is established between endpoints. Then if 
> /proc/sys/net/sctp/auth_enable is set 1, a received AUTH chunk will 
> cause kernel panic.
 ...
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
