From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: set route type for anycast routes
Date: Thu, 16 Mar 2017 20:41:11 -0700 (PDT)
Message-ID: <20170316.204111.427731399512369532.davem@davemloft.net>
References: <1489626873-5371-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751930AbdCQDlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:41:13 -0400
In-Reply-To: <1489626873-5371-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 15 Mar 2017 18:14:33 -0700

> Anycast routes have the RTF_ANYCAST flag set, but when dumping routes
> for userspace the route type is not set to RTN_ANYCAST. Make it so.
> 
> Fixes: 58c4fb86eabcb ("[IPV6]: Flag RTF_ANYCAST for anycast routes")
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Good catch, applied, thanks.
