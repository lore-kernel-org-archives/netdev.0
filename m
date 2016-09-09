From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vti: use right inner_mode for inbound inter address
 family policy checks
Date: Thu, 08 Sep 2016 17:17:57 -0700 (PDT)
Message-ID: <20160908.171757.1653874905057849577.davem@davemloft.net>
References: <20160904105713.3mqgszgqi7waxk5l@toau>
        <20160906111522.GG31137@gauss.secunet.com>
        <20160907184038.2neg44xtvlunlrmu@toau>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: thomas.zeitlhofer+lkml@ze-it.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42820 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbcIIAR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:17:58 -0400
In-Reply-To: <20160907184038.2neg44xtvlunlrmu@toau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: thomas.zeitlhofer+lkml@ze-it.at
Date: Wed, 7 Sep 2016 20:40:38 +0200

> In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
> vti6), the inbound policy checks in vti_rcv_cb() and vti6_rcv_cb() are
> using the wrong address family. As a result, all inbound inter address
> family traffic is dropped.
> 
> Use the xfrm_ip2inner_mode() helper, as done in xfrm_input() (i.e., also
> increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error), to select the
> inner_mode that contains the right address family for the inbound policy
> checks.
> 
> Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>

Steffen please review this new version of the patch.

Thanks.
