From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/4] gtp: support multiple APN's per GTP endpoint
Date: Tue, 14 Mar 2017 14:42:16 +0100
Message-ID: <20170314134216.GA4170@salvia>
References: <20170314112548.24027-1-aschultz@tpip.net>
 <20170314114538.GC2992@salvia>
 <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40656 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751837AbdCNNm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 09:42:27 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 54A5BE7B82
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:42:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 45067DA875
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:42:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1EBD7DA87B
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:42:21 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 01:42:44PM +0100, Andreas Schultz wrote:
> > It is definitely not acceptable to break the existing API.
> 
> The specific use case of the API that is no longer supported was never used by
> anyone. [...]

Yes, this was used openggsn and I tested this with a full blown FOSS
setup. Yes, a toy thing compared to the proprietary equipment you deal
with, but we always started with things like this.

> The only supported and documented API for the GTP module is libgtpnl.

No, the netlink interface itself if the API.

Stopping trying to find a reason to break API, that is a no-go.
