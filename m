From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dst: move cpu inside ifdef to avoid
 compilation warning
Date: Tue, 10 Oct 2017 15:56:10 -0700 (PDT)
Message-ID: <20171010.155610.850033027052384746.davem@davemloft.net>
References: <20171010220539.21200-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755376AbdJJW4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 18:56:13 -0400
In-Reply-To: <20171010220539.21200-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 10 Oct 2017 15:05:39 -0700

> If CONFIG_DST_CACHE is not selected cpu variable
> will be unused and we will see a compilation warning.
> Move it under the ifdef.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: d66f2b91f95b ("bpf: don't rely on the verifier lock for metadata_dst allocation")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
