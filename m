From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] BPF metadata for direct access
Date: Tue, 26 Sep 2017 13:37:32 -0700 (PDT)
Message-ID: <20170926.133732.1980264928194037130.davem@davemloft.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964856AbdIZUhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 16:37:33 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 25 Sep 2017 02:25:49 +0200

> This work enables generic transfer of metadata from XDP into skb,
> meaning the packet has a flexible and programmable room for meta
> data, which can later be used by BPF to set various skb members
> when passing up the stack. For details, please see second patch.
> Support has been implemented and tested with two drivers, and
> should be straight forward to add to other drivers as well which
> properly support head adjustment already.

Series applied, thanks.

We're accumulating features again and leaving some drivers behind,
let's not allow this to get out of hand for XDP_REDIRECT and this
stuff.

Thanks.
