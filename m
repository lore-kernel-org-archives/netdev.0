From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Tue, 06 May 2008 13:31:53 -0700 (PDT)
Message-ID: <20080506.133153.68569175.davem@davemloft.net>
References: <Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
	<20080427.164016.01806730.davem@davemloft.net>
	<20080506131054.fb6196cf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, horms@verge.net.au,
	bugme-daemon@bugzilla.kernel.org, l0op8ack@hotmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932605AbYEFUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:31:58 -0400
In-Reply-To: <20080506131054.fb6196cf.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 6 May 2008 13:10:54 -0700

> On Sun, 27 Apr 2008 16:40:16 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Julian Anastasov <ja@ssi.bg>
> > Date: Sat, 26 Apr 2008 20:48:46 +0300 (EEST)
> > 
> > > 	Result from ip_vs_proto_get() should be checked because
> > > protocol value can be invalid or unsupported in backup. Also, add
> > > checks to validate message limits and connection state.
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > 
> > This patch looks great, and fixes real bugs regardless of the
> > effect upon the bug report in question.
> > 
> > I would really like to see this fix tested, because if it fixes
> > the specific bug, all the better, and we should indicate this in
> > the changelog message.
> 
> The reporter (L0op8ack <l0op8ack@hotmail.com>) has used the bugzilla web
> interface to confirm that this patch fixes 2.6.24.4.

Great, thanks for the update.
