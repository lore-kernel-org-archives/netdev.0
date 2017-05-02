From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 02 May 2017 13:00:32 -0400 (EDT)
Message-ID: <20170502.130032.1854491688518080191.davem@davemloft.net>
References: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
        <20170502082531.43b32e05@xeon-e3>
        <7fa44ec5-9a3a-55d1-b058-540d37ef01bd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbdEBRAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 13:00:36 -0400
In-Reply-To: <7fa44ec5-9a3a-55d1-b058-540d37ef01bd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 2 May 2017 10:51:23 -0600

> On 5/2/17 9:25 AM, Stephen Hemminger wrote:
>> Please either use existing netlink attribute code in libnetlink.h
>> (rta_getattr_u32 etc) or use libmnl like devlink.
> 
> All of the existing rta_ functions take a struct rta_attr; netlink
> messages use struct nlattr. It's just wrong to use rta functions for
> netlink messages.

Agreed.

> There is no existing parse function for nlattr. There is no existing
> validate function - for nlattr or rta_attr. So I do not see any overlap
> with existing code.

Also agreed.
