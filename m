From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix endian issue in logical link config
 command
Date: Thu, 30 Mar 2017 15:59:07 -0700 (PDT)
Message-ID: <20170330.155907.2074189419927967788.davem@davemloft.net>
References: <suresh.reddy@broadcom.com>
        <20170330045832.2287-1-suresh.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: suresh.reddy@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdC3W7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 18:59:09 -0400
In-Reply-To: <20170330045832.2287-1-suresh.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>
Date: Thu, 30 Mar 2017 00:58:32 -0400

> Use cpu_to_le32() for link_config variable in set_logical_link_config
> command as this variable is of type u32.
> 
> Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>

Applied.
