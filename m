From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] qed: Fix stack corruption on probe
Date: Tue, 20 Sep 2016 04:57:50 -0400 (EDT)
Message-ID: <20160920.045750.166537005858505924.davem@davemloft.net>
References: <1474296461-22558-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.com,
        Yuval.Mintz@caviumnetworks.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbcITI5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:57:53 -0400
In-Reply-To: <1474296461-22558-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 19 Sep 2016 17:47:41 +0300

> Commit fe56b9e6a8d95 ("qed: Add module with basic common support")
> has introduced a stack corruption during probe, where filling a
> local struct with data to be sent to management firmware is incorrectly
> filled; The data is written outside of the struct and corrupts
> the stack.
> 
> Changes from v1:
> ----------------
>  - Correct the value written [Caught by David Laight]
> 
> Fixes: fe56b9e6a8d95 ("qed: Add module with basic common support")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>

Applied, thanks.
