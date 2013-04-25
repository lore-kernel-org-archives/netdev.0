From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] bridge: do not expire mdb entry as long as
 bridge still uses it
Date: Thu, 25 Apr 2013 18:07:01 +0800
Message-ID: <1366884421.11488.4.camel@cr0>
References: <1366878083-22797-1-git-send-email-amwang@redhat.com>
	 <20130425083704.GA27420@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab3DYKHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 06:07:25 -0400
In-Reply-To: <20130425083704.GA27420@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 16:37 +0800, Herbert Xu wrote:
> 
> As you're saying the bridge interface's subscription is expiring
> incorrectly, the question is why aren't we receiving those group
> reports from ourselves, which should be sent out periodically if
> we were subscribed to the group?

I thought IGMP report is optional as long as the multicast traffic is
still running. If it is mandatory, I don't see any IGMP report sending
out from guest, so the bug is in IPv4 multicast code rather than bridge
code.

But this can't explain why guests can communicate with each other. :)
