From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 16:42:36 +0200
Message-ID: <1497451356.9377.1.camel@sipsolutions.net>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38904 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751934AbdFNOmn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:42:43 -0400
In-Reply-To: <1497450634-3581-1-git-send-email-cugyly@163.com> (sfid-20170614_163132_934852_0520825B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 22:30 +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> 
> yuan linyu (11):
>   ipv6: skb_put_zero() used to optimize code
>   ipv4: skb_put_zero() used to optimize code
>   ncsi: skb_put_zero() used to optimize code
>   dsa: skb_put_zero() used to optimize code
>   key: skb_put_zero() used to optimize code
>   openvswitch: skb_put_zero() used to optimize code
>   batman-adv: skb_put_zero() used to optimize code
>   bridge: skb_put_zero() used to optimize code
>   sctp: skb_put_zero() used to optimize code
>   atm: skb_put_zero() used to optimize code
>   qrtr: skb_put_zero() used to optimize code

Hmm. I guess my spatch missed these because of the casts present in
them.

Surely you didn't do them by hand, so maybe you should provide a single
big patch with the spatch?

johannes
