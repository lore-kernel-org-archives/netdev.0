From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 11:43:25 -0700 (PDT)
Message-ID: <20170831.114325.2027598728601121750.davem@davemloft.net>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdHaSn0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:43:26 -0400
In-Reply-To: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 30 Aug 2017 22:18:13 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This extends bridge fdb table tracepoints to also cover
> learned fdb entries in the br_fdb_update path. Note that
> unlike other tracepoints I have moved this to when the fdb
> is modified because this is in the datapath and can generate
> a lot of noise in the trace output. br_fdb_update is also called
> from added_by_user context in the NTF_USE case which is already
> traced ..hence the !added_by_user check.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.

Let's use dev->name for now and if the tooling can eventually
do transparent ifindex->name then we can consider redoing
a bunch of networking tracepoints.

Thanks.
