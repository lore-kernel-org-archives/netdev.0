From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/2] bridge: add flags to distinguish permanent mdb
 entires
Date: Mon, 17 Dec 2012 13:46:09 +0800
Message-ID: <1355723169.23943.3.camel@cr0>
References: <1355558992-32285-1-git-send-email-amwang@redhat.com>
	 <1355558992-32285-2-git-send-email-amwang@redhat.com>
	 <20121215.171656.1197452765852503859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.hengli.com.au, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727Ab2LQFrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 00:47:22 -0500
In-Reply-To: <20121215.171656.1197452765852503859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-15 at 17:16 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Sat, 15 Dec 2012 16:09:51 +0800
> 
> > This patch adds a flag to each mdb entry, so that we can distinguish
> > permanent entries with temporary entries.
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Applied, but you _really_ need to lock down the interface and
> stop making changes to the user visible side of this _now_.
> 

OK. I think it is okay to break ABI at this time, since the merge window
is not closed yet, who will develop applications based on an unstable
kernel though. :-/
