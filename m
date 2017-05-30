From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Don't log missing periodic stats by default
Date: Tue, 30 May 2017 12:38:21 -0400 (EDT)
Message-ID: <20170530.123821.215989310734091673.davem@davemloft.net>
References: <1496046289-17330-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdE3QiX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:38:23 -0400
In-Reply-To: <1496046289-17330-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Mon, 29 May 2017 11:24:49 +0300

> Current implementation lacks the logic for providing management
> firmware with RDMA-related statistics; [much] worse than that -
> it logs such events by default to system logs.
> 
> Since the statistics' gathering is done periodically, using sufficiently
> new management firmware the system logs would get filled with these
> unnecessary prints.
> 
> For now, reduce the verbosity of the log so that it would not be
> logged by default.
> 
> Fixes: 6c75424612a7 ("qed: Add support for NCSI statistics")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
