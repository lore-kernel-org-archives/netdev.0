From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 18:31:48 +0200
Message-ID: <1497457908.9377.4.camel@sipsolutions.net>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B) <1497451356.9377.1.camel@sipsolutions.net>
         <1497452424.3765.3.camel@163.com>
         <1497457773.9377.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: cugyly@163.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39702 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750735AbdFNQbv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 12:31:51 -0400
In-Reply-To: <1497457773.9377.2.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 18:29 +0200, Johannes Berg wrote:
> On Wed, 2017-06-14 at 23:00 +0800, yuan linyu wrote:
> 
> > sorry, I do them by hand. 
> 
> oh, ok.
> 
> This seems to work:
> 
> @@
> identifier p;
> expression len;
> expression skb;
> type t;
> @@
> -p = (t)skb_put(skb, len);
> -memset(p, 0, len);
> +p = (t)skb_put_zero(skb, len);

Nope, still didn't find everything - not the batman and atm cases for
example. But still a few more, I think that you didn't find, e.g. in
mac80211.

Anyway - I think none of this is really critical.

johannes
