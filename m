From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Add comment that early_demux can change
 via sysctl
Date: Mon, 28 Aug 2017 15:17:42 -0700 (PDT)
Message-ID: <20170828.151742.1055662876302049959.davem@davemloft.net>
References: <1503958460-20765-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1WRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:17:43 -0400
In-Reply-To: <1503958460-20765-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 28 Aug 2017 15:14:20 -0700

> Twice patches trying to constify inet{6}_protocol have been reverted:
> 39294c3df2a8 ("Revert "ipv6: constify inet6_protocol structures"") to
> revert 3a3a4e3054137 and then 03157937fe0b5 ("Revert "ipv4: make
> net_protocol const"") to revert aa8db499ea67.
> 
> Add a comment that the structures can not be const because the
> early_demux field can change based on a sysctl.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
