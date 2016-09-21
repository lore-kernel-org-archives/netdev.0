From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 net-next 00/15] BPF hardware offload (cls_bpf for now)
Date: Wed, 21 Sep 2016 19:56:00 -0400 (EDT)
Message-ID: <20160921.195600.1809838520295604067.davem@davemloft.net>
References: <1474454647-20137-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbcIUX4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:56:09 -0400
In-Reply-To: <1474454647-20137-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 21 Sep 2016 11:43:52 +0100

> In the last year a lot of progress have been made on offloading
> simpler TC classifiers.  There is also growing interest in using
> BPF for generic high-speed packet processing in the kernel.
> It seems beneficial to tie those two trends together and think
> about hardware offloads of BPF programs.  This patch set presents
> such offload to Netronome smart NICs.  cls_bpf is extended with
> hardware offload capabilities and NFP driver gets a JIT translator
> which in presence of capable firmware can be used to offload
> the BPF program onto the card.
> 
> BPF JIT implementation is not 100% complete (e.g. missing instructions)
> but it is functional.  Encouragingly it should be possible to
> offload most (if not all) advanced BPF features onto the NIC - 
> including packet modification, maps, tunnel encap/decap etc.
 ...

Series applied, thanks.
