From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/5] powerpc: remove fsl,fman from
 of_device_ids[]
Date: Mon, 19 Dec 2016 10:37:12 -0500 (EST)
Message-ID: <20161219.103712.1578523196484939315.davem@davemloft.net>
References: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
        <1482139343-8975-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, scott.wood@nxp.com,
        mpe@ellerman.id.au
To: madalin.bucur@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754968AbcLSPhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 10:37:20 -0500
In-Reply-To: <1482139343-8975-3-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 19 Dec 2016 11:22:20 +0200

> The fsl/fman drivers will use of_platform_populate() on all
> supported platforms.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>

It seems that this creates a failure point between patches #2 and
#3.  If the cases handled by this "fsl,fman" entry are only afterwards
covered by the of_platform_populate() code added in patch #3 then you
cannot split these two changes up like this.

The two changes must be done at the same time, otherwise probing will
fail for some people between patches #2 and #3.
