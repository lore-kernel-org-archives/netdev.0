From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rtnetlink: plumb extended ack to doit
 function
Date: Mon, 17 Apr 2017 15:45:10 -0400 (EDT)
Message-ID: <20170417.154510.1235069954550923423.davem@davemloft.net>
References: <1492361304-6116-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753700AbdDQTpM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:45:12 -0400
In-Reply-To: <1492361304-6116-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 16 Apr 2017 09:48:24 -0700

> Add netlink_ext_ack arg to rtnl_doit_func. Pass extack arg to nlmsg_parse
> for doit functions that call it directly.
> 
> This is the first step to using extended error reporting in rtnetlink.
> From here individual subsystems can be updated to set netlink_ext_ack as
> needed.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
