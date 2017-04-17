From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: send unsolicited NA on admin up
Date: Mon, 17 Apr 2017 12:45:58 -0400 (EDT)
Message-ID: <20170417.124558.1234386951708658418.davem@davemloft.net>
References: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754743AbdDQQqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 12:46:44 -0400
In-Reply-To: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 12 Apr 2017 11:49:04 -0700

> ndisc_notify is the ipv6 equivalent to arp_notify. When arp_notify is
> set to 1, gratuitous arp requests are sent when the device is brought up.
> The same is expected when ndisc_notify is set to 1 (per ndisc_notify in
> Documentation/networking/ip-sysctl.txt). The NA is not sent on NETDEV_UP
> event; add it.
> 
> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
