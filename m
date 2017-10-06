From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_gre: check packet length and mtu correctly
 in erspan_fb_xmit
Date: Fri, 06 Oct 2017 23:22:29 +0100 (WEST)
Message-ID: <20171006.232229.74190380417429379.davem@davemloft.net>
References: <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com>
        <063D6719AE5E284EB5DD2968C1650D6DD008B9C8@AcuExch.aculab.com>
        <CALDO+SYDGtipnsXOmcFmCRB2QcgjjzoWVB=T71=r7U834ivPjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
        lucien.xin@gmail.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdJFWXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:23:19 -0400
In-Reply-To: <CALDO+SYDGtipnsXOmcFmCRB2QcgjjzoWVB=T71=r7U834ivPjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 6 Oct 2017 15:09:29 -0700

> Yes, adding another field in the struct net_device can avoid the
> arithmetic operation. I'm not sure it's a good idea to add new field
> since there are already a lot in net_device.  Let's wait to see how
> others think.

Why would you add it to net_device when you can add it to ip_tunnel?
