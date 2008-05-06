From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Tue, 6 May 2008 13:10:54 -0700
Message-ID: <20080506131054.fb6196cf.akpm@linux-foundation.org>
References: <bug-10556-10286@http.bugzilla.kernel.org/>
	<20080426040452.4fcbc962.akpm@linux-foundation.org>
	<Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
	<20080427.164016.01806730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, horms@verge.net.au,
	bugme-daemon@bugzilla.kernel.org, l0op8ack@hotmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57875 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753171AbYEFULw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:11:52 -0400
In-Reply-To: <20080427.164016.01806730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 27 Apr 2008 16:40:16 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat, 26 Apr 2008 20:48:46 +0300 (EEST)
> 
> > 	Result from ip_vs_proto_get() should be checked because
> > protocol value can be invalid or unsupported in backup. Also, add
> > checks to validate message limits and connection state.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> This patch looks great, and fixes real bugs regardless of the
> effect upon the bug report in question.
> 
> I would really like to see this fix tested, because if it fixes
> the specific bug, all the better, and we should indicate this in
> the changelog message.

The reporter (L0op8ack <l0op8ack@hotmail.com>) has used the bugzilla web
interface to confirm that this patch fixes 2.6.24.4.

