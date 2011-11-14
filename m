From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction
 during fast recovery
Date: Mon, 14 Nov 2011 01:45:53 -0500 (EST)
Message-ID: <20111114.014553.1681524020036516686.davem@davemloft.net>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com>
	<CAK6E8=dXtgi+W9JQg9ruwU8JxYJf-T7OMad7RhNckFAxsYFndg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, nanditad@google.com, therbert@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab1KNGqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 01:46:05 -0500
In-Reply-To: <CAK6E8=dXtgi+W9JQg9ruwU8JxYJf-T7OMad7RhNckFAxsYFndg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue, 8 Nov 2011 17:18:34 -0800

> On Tue, Nov 8, 2011 at 10:07 AM, Neal Cardwell <ncardwell@google.com> wrote:
>> Fixes for some issues that prevent DSACKs from allowing TCP senders to
>> undo cwnd reductions made during fast recovery.
 ...
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> 
> FWIW. This undo-fix patch on Google Web servers increased the undos in
> loss by 46% and in disorder by 17%. It also corrects the SNMP stats
> TCPTimeouts, TCPRenoFailures, TCPSackFailures by moving state into
> open, instead of disorder, after recovery.

Just wanted to give you guys a heads-up that this patch will take me
some time to review properly.
