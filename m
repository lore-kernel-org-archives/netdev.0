From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: missing call of trace_napi_poll in busy_poll_stop
Date: Mon, 28 Aug 2017 11:23:02 -0700 (PDT)
Message-ID: <20170828.112302.1784646762321597446.davem@davemloft.net>
References: <150366627224.16965.12554507587831320156.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdH1SXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:23:03 -0400
In-Reply-To: <150366627224.16965.12554507587831320156.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 25 Aug 2017 15:04:32 +0200

> Noticed that busy_poll_stop() also invoke the drivers napi->poll()
> function pointer, but didn't have an associated call to trace_napi_poll()
> like all other call sites.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks.
