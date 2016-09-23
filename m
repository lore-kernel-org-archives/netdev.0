From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: xgene: Fix MSS programming
Date: Fri, 23 Sep 2016 08:21:32 -0400 (EDT)
Message-ID: <20160923.082132.1550198525968986550.davem@davemloft.net>
References: <1474584453-9071-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, toanle@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757912AbcIWMVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:21:35 -0400
In-Reply-To: <1474584453-9071-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 22 Sep 2016 15:47:33 -0700

> Current driver programs static value of MSS in hardware register for TSO
> offload engine to segment the TCP payload regardless the MSS value
> provided by network stack.
> 
> This patch fixes this by programming hardware registers with the
> stack provided MSS value.
> 
> Since the hardware has the limitation of having only 4 MSS registers,
> this patch uses reference count of mss values being used.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Toan Le <toanle@apm.com>

Applied.
