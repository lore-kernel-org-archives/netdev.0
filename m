From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 21:29:03 -0700 (PDT)
Message-ID: <20170926.212903.454497939014837374.davem@davemloft.net>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965486AbdI0E3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:29:04 -0400
In-Reply-To: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 25 Sep 2017 12:23:34 +0200

> From: Simon Horman <simon.horman@netronome.com>
> 
> John says:
> 
> This patch set allows offloading of TC flower match and set tunnel fields
> to the NFP. The initial focus is on VXLAN traffic. Due to the current
> state of the NFP firmware, only VXLAN traffic on well known port 4789 is
> handled. The match and action fields must explicity set this value to be
> supported. Tunnel end point information is also offloaded to the NFP for
> both encapsulation and decapsulation. The NFP expects 3 separate data sets
> to be supplied.
 ...

Series applied, thanks.

I see there is some discussion about ipv6 flow dissector key handling
and ND keepalives, but those should be addressable in follow-on changes.

Thanks.
