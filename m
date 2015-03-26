From: Vasily Khoruzhick <anarsoul@gmail.com>
Subject: Regression since e0b46d0ee9c240c7430a47e9b0365674d4a04522
Date: Thu, 26 Mar 2015 11:18:29 +0300
Message-ID: <CA+E=qVfyt_8VrRLwS9bJaZ+QamFDdAtXviODV9y4uZt6tjNEow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Monam Agarwal <monamagarwal123@gmail.com>,
	Xi Wang <xii@google.com>, Christoph Hellwig <hch@lst.de>,
	Jeff Layton <jlayton@primarydata.com>,
	Tom Gundersen <teg@jklm.no>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:32782 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbCZISv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 04:18:51 -0400
Received: by lbcmq2 with SMTP id mq2so35448431lbc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 01:18:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Juniper VPN client is not working since upgrade to linux-3.19,

I did a bisect between v3.18 and v3.19 and it shows that culprit is:

Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Nov 7 21:22:23 2014 +0800

   tun: Use iovec iterators


I wasn't able to revert this patch, since result doesn't compile due
to lack of skb_copy_datagram_const_iovec()

I can't analyze what happens on Juniper VPN client, since I have no
access to its source code (it's provided in binary form only).

Regards,
Vasily
