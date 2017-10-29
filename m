From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: allow usage in namespaces
Date: Sun, 29 Oct 2017 11:56:05 +0900 (KST)
Message-ID: <20171029.115605.2002054524331305665.davem@davemloft.net>
References: <20171027180823.31144-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: mcroce@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdJ2C4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 22:56:09 -0400
In-Reply-To: <20171027180823.31144-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce <mcroce@redhat.com>
Date: Fri, 27 Oct 2017 20:08:23 +0200

> Check for CAP_NET_ADMIN with ns_capable() instead of capable()
> to allow usage of ppp in user namespace other than the init one.
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Ok, applied to net-next.
