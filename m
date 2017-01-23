From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: ignore null_entry on route dumps
Date: Sun, 22 Jan 2017 23:58:29 -0500 (EST)
Message-ID: <20170122.235829.1911961579892347071.davem@davemloft.net>
References: <1485147377-11922-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdAWE6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:58:32 -0500
In-Reply-To: <1485147377-11922-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David, please slow down.

How is the NULL entry getting selected to be dumped and passed
down here in the first place?

The problem seems to be higher up in the chain here, don't
just special case check for this in rt6_dump_route().

Thanks.
