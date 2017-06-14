From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 18:29:33 +0200
Message-ID: <1497457773.9377.2.camel@sipsolutions.net>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B) <1497451356.9377.1.camel@sipsolutions.net>
         <1497452424.3765.3.camel@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: cugyly@163.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39662 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752358AbdFNQ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 12:29:39 -0400
In-Reply-To: <1497452424.3765.3.camel@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 23:00 +0800, yuan linyu wrote:

> sorry, I do them by hand. 

oh, ok.

This seems to work:

@@
identifier p;
expression len;
expression skb;
type t;
@@
-p = (t)skb_put(skb, len);
-memset(p, 0, len);
+p = (t)skb_put_zero(skb, len);

johannes
