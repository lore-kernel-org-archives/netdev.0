From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Use inbound ifaddr as source addresses for
 ICMPv6 errors
Date: Wed, 31 Aug 2016 20:59:06 -0700 (PDT)
Message-ID: <20160831.205906.751461157991798139.davem@davemloft.net>
References: <20160828033406.11269-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754198AbcIAD7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 23:59:07 -0400
In-Reply-To: <20160828033406.11269-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Sun, 28 Aug 2016 11:34:06 +0800

> According to RFC 1885 2.2(c), the source address of ICMPv6
> errors in response to forwarded packets should be set to the
> unicast address of the forwarding interface in order to be helpful
> in diagnosis. Currently the selection of source address is based
> on the default route, without respect to the inbound interface.
> 
> This patch sets the source address of ICMPv6 error messages to
> the address of inbound interface, with the exception of
> 'time exceeded' and 'packet to big' messages sent in ip6_forward(),
> where the address of OUTPUT device is forced as source address
> (however, it is NOT enforced as claimed without this patch).
> 
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

Please resubmit with an updated commit message describing
the use case.
