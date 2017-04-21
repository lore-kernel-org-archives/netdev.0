From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: don't deliver packets with zero length to
 raw sockets
Date: Fri, 21 Apr 2017 10:53:32 -0400 (EDT)
Message-ID: <20170421.105332.1898209845543083717.davem@davemloft.net>
References: <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
        <20170421100112.GA4824@bistromath.localdomain>
        <CAOTh05AEQe=QMoStwdXckQ7pPW_ZuDAAj5W78rNqSR-6hNZGSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: jbainbri@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424205AbdDUS5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:57:31 -0400
In-Reply-To: <CAOTh05AEQe=QMoStwdXckQ7pPW_ZuDAAj5W78rNqSR-6hNZGSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Bainbridge <jbainbri@redhat.com>
Date: Fri, 21 Apr 2017 21:18:00 +1000

> I cannot see the use in delivering a skb with zero bytes after the
> network header to a raw socket.

Then it cannot be used to look at zero length UDP packets, which are
completely legal and used.

So we must deliver it.
