From: David Miller <davem@davemloft.net>
Subject: Re: [PLEASE REVERT] "Add a WARN_ON_ONCE" at
 net/sched/sch_generic.c:
Date: Sun, 25 May 2008 05:10:32 -0700 (PDT)
Message-ID: <20080525.051032.186144643.davem@davemloft.net>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: komurojun-mbn@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50860
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754189AbYEYMKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 08:10:37 -0400
In-Reply-To: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Komuro <komurojun-mbn@nifty.com>
Date: Sun, 25 May 2008 11:23:08 +0900

> Please revert the patch "Add a WARN_ON_ONCE() to
>  the transmit timeout function".
> 
> The transmit timeout sometimes happens on normal operation.
> This message annoys me.

Sometimes, but not often.

Most of the time it does indicate a bug and we absolutely cannot
diagnose it without the backtrace.
