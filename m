From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: send unsolicited NA if enabled
 for all interfaces
Date: Mon, 24 Apr 2017 14:07:39 -0400 (EDT)
Message-ID: <20170424.140739.1331231856062483547.davem@davemloft.net>
References: <1492877413-21906-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S976560AbdDXSHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:07:41 -0400
In-Reply-To: <1492877413-21906-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 22 Apr 2017 09:10:13 -0700

> When arp_notify is set to 1 for either a specific interface or for 'all'
> interfaces, gratuitous arp requests are sent. Since ndisc_notify is the
> ipv6 equivalent to arp_notify, it should follow the same semantics.
> Commit 4a6e3c5def13 ("net: ipv6: send unsolicited NA on admin up") sends
> the NA on admin up. The final piece is checking devconf_all->ndisc_notify
> in addition to the per device setting. Add it.
> 
> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - update commit message with subject of commit 4a6e3c5def13 per comment
>   from Sergei

Applied, thanks David.
