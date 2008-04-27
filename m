From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Sun, 27 Apr 2008 16:40:16 -0700 (PDT)
Message-ID: <20080427.164016.01806730.davem@davemloft.net>
References: <bug-10556-10286@http.bugzilla.kernel.org/>
	<20080426040452.4fcbc962.akpm@linux-foundation.org>
	<Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	horms@verge.net.au, bugme-daemon@bugzilla.kernel.org,
	l0op8ack@hotmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760051AbYD0XkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 19:40:16 -0400
In-Reply-To: <Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 26 Apr 2008 20:48:46 +0300 (EEST)

> 	Result from ip_vs_proto_get() should be checked because
> protocol value can be invalid or unsupported in backup. Also, add
> checks to validate message limits and connection state.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

This patch looks great, and fixes real bugs regardless of the
effect upon the bug report in question.

I would really like to see this fix tested, because if it fixes
the specific bug, all the better, and we should indicate this in
the changelog message.
