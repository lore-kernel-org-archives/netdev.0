From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 01/11] ipv6: skb_put_zero() used to optimize
 code
Date: Wed, 14 Jun 2017 21:51:23 +0200
Message-ID: <1497469883.9377.6.camel@sipsolutions.net>
References: <1497451026-3923-1-git-send-email-cugyly@163.com>
         <20170614084434.3342671d@xeon-e3>
         <1497466892.9377.5.camel@sipsolutions.net>
         <20170614121416.63a78b0d@xeon-e3> (sfid-20170614_211424_579385_35B01873)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41204 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751777AbdFNTv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:51:29 -0400
In-Reply-To: <20170614121416.63a78b0d@xeon-e3> (sfid-20170614_211424_579385_35B01873)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 12:14 -0700, Stephen Hemminger wrote:
> 
> > I just copied it from skb_put() - you could ask the same there? :)
> 
> My taste is to  have less casts. Never understood why so many skb_
> functions returned char *, probably a leftover from older Unix style.

I agree, for many of them it's awkward and I often just put a (void *)
cast in there ...

I guess we can just make them void, and if anyone wants it I can easily
cook up an spatch to remove casts.

johannes
