From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] XDP redirect tracepoints
Date: Tue, 29 Aug 2017 10:51:43 -0700 (PDT)
Message-ID: <20170829.105143.829989946050016565.davem@davemloft.net>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2Rvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:51:44 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Aug 2017 16:37:35 +0200

> I feel this is as far as I can take the tracepoint infrastructure to
> assist XDP monitoring.
> 
> Tracepoints comes with a base overhead of 25 nanosec for an attached
> bpf_prog, and 48 nanosec for using a full perf record. This is
> problematic for the XDP use-case, but it is very convenient to use the
> existing perf infrastructure.
> 
>>From a performance perspective, the real solution would be to attach
> another bpf_prog (that understand xdp_buff), but I'm not sure we want
> to introduce yet another bpf attach API for this.
> 
> One thing left is to standardize the possible err return codes, to a
> limited set, to allow easier (and faster) mapping into a bpf map.

Series applied, thanks Jesper.
