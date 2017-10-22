From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: fix returning of vlan range op errors
Date: Sun, 22 Oct 2017 01:52:08 +0100 (WEST)
Message-ID: <20171022.015208.1040885785483187060.davem@davemloft.net>
References: <1508433452-23812-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        roopa@cumulusnetworks.com, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932269AbdJVAwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 20:52:11 -0400
In-Reply-To: <1508433452-23812-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 19 Oct 2017 20:17:32 +0300

> When vlan tunnels were introduced, vlan range errors got silently
> dropped and instead 0 was returned always. Restore the previous
> behaviour and return errors to user-space.
> 
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable.
