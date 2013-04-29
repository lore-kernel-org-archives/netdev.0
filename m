From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 1/3] bridge: use the bridge IP addr as source
 addr of querier
Date: Mon, 29 Apr 2013 16:17:38 +0800
Message-ID: <1367223458.2479.4.camel@cr0>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
	 <20130429074301.GA14021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675Ab3D2IRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 04:17:55 -0400
In-Reply-To: <20130429074301.GA14021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 15:43 +0800, Herbert Xu wrote:
> On Mon, Apr 29, 2013 at 03:26:30PM +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > Quote from Adam:
> > "If it is believed that the use of 0.0.0.0
> > as the IP address is what is causing strange behaviour on other devices
> > then is there a good reason that a bridge rather than a router shouldn't
> > be the active querier? If not then using the bridge IP address and
> > having the querier enabled by default may be a reasonable solution
> > (provided that our querier obeys the election rules and shuts up if it
> > sees a query from a lower IP address that isn't 0.0.0.0). Just because a
> > device is the elected querier for IGMP doesn't appear to mean it is
> > required to perform any other routing functions."
> 
> I don't think we should make this the default.  Having it as an
> option though is fine with me.  We may also want to allow the user
> to explicitly set an IP address.

Good point. I think we should at least make it a boolen option, I am not
sure if allowing users to explicitly set it is overkill.

Thanks.
