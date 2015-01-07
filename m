From: Billy Shuman <wshuman3@gmail.com>
Subject: [bisected] no traffic on ssl vpn with 3.19rc1 - 3.19rc3
Date: Wed, 7 Jan 2015 14:10:41 -0500
Message-ID: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:60671 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbAGTKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:10:42 -0500
Received: by mail-yk0-f171.google.com with SMTP id 142so881814ykq.2
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:10:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Since 3.19rc1 I get 100% packet loss through SSL vpn.  I bisected with
the following result:

0b46d0ee9c240c7430a47e9b0365674d4a04522 is the first bad commit
commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Nov 7 21:22:23 2014 +0800

    tun: Use iovec iterators

    This patch removes the use of skb_copy_datagram_const_iovec in
    favour of the iovec iterator-based skb_copy_datagram_iter.


https://bugzilla.kernel.org/show_bug.cgi?id=90901


Thanks,
Billy Shuman
