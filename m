From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] ipv6: drop ipv6_sk_mc_lock in mcast
Date: Wed, 10 Sep 2014 15:36:10 -0700
Message-ID: <CAM_iQpVY832KKK46Gm44n3X9LXomcH+zbxp3obXPKANMB+kZzg@mail.gmail.com>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410306738-18036-5-git-send-email-xiyou.wangcong@gmail.com>
	<20140910171623.GA12299@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:62654 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 18:36:10 -0400
Received: by mail-oa0-f51.google.com with SMTP id n16so13674539oag.24
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 15:36:10 -0700 (PDT)
In-Reply-To: <20140910171623.GA12299@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 10:16 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>
> Just a small thing: there are a few comments in the file that still
> refer to this lock (as ipv6_sk_mc_lock or ip6_sk_mc_lock):
>

Yeah, I missed it. But it is already out of date since RCU conversion.
I will fix the comment in a separated patch in the next update.

Thanks.
