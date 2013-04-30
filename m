From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 2/3] bridge: only expire the mdb entry when
 query is received
Date: Tue, 30 Apr 2013 11:17:37 +0800
Message-ID: <1367291857.3216.2.camel@cr0>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
	 <1367220392-17496-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758614Ab3D3DRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 23:17:55 -0400
In-Reply-To: <1367220392-17496-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 15:26 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Currently we arm the expire timer when the mdb entry is added,
> however, this causes problem when there is no querier sent
> out after that.
> 
> So we should only arm the timer when a corresponding query is
> received, as suggested by Herbert.

One problem with this solution is that the temp mdb entry will no longer
be expired automatically any more, since no query no timer.

I am wondering if we should find other way to fix it, for example,
touching the timer as long as there is multicast traffic (non-IGMP).

Thanks!
