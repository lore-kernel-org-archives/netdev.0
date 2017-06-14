From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 23:00:24 +0800
Message-ID: <1497452424.3765.3.camel@163.com>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B) <1497451356.9377.1.camel@sipsolutions.net>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:35649 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752062AbdFNPB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 11:01:56 -0400
In-Reply-To: <1497451356.9377.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 三, 2017-06-14 at 16:42 +0200, Johannes Berg wrote:
> On Wed, 2017-06-14 at 22:30 +0800, yuan linyu wrote:
> > 
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > 
> > 
> > yuan linyu (11):
> >   ipv6: skb_put_zero() used to optimize code
> >   ipv4: skb_put_zero() used to optimize code
> >   ncsi: skb_put_zero() used to optimize code
> >   dsa: skb_put_zero() used to optimize code
> >   key: skb_put_zero() used to optimize code
> >   openvswitch: skb_put_zero() used to optimize code
> >   batman-adv: skb_put_zero() used to optimize code
> >   bridge: skb_put_zero() used to optimize code
> >   sctp: skb_put_zero() used to optimize code
> >   atm: skb_put_zero() used to optimize code
> >   qrtr: skb_put_zero() used to optimize code
> Hmm. I guess my spatch missed these because of the casts present in
> them.
> 
> Surely you didn't do them by hand, so maybe you should provide a single
> big patch with the spatch?
sorry, I do them by hand. 
last time when i try to change ndisc.c, david adhern suggest to use skb_put_zero().
> 
> johannes
