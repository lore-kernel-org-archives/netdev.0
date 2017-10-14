From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] nfp: bpf: support direct packet access
Date: Sat, 14 Oct 2017 11:13:45 -0700 (PDT)
Message-ID: <20171014.111345.2200540382966516687.davem@davemloft.net>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdJNSNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:13:46 -0400
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 12 Oct 2017 10:34:06 -0700

> The core of this series is direct packet access support.  With a
> small change to the verifier, the offloaded code can now make
> use of DPA.  We need to be careful to use kernel (after initial
> translation) offsets in our JIT.  Direct packet access also brings
> us to the problem of eBPF endianness.  After considering the 
> changes necessary we decided to not support translation on both
> BE and LE hosts, for now.
> 
> This series contains two fixes - one for compare instructions and
> one for ineffective jne optimization.  I chose to include fixes
> in this set because the code in -net works only with unreleased
> PoC FW (ABI version 1) and therefore nobody outside of Netronome
> can exercise it anyway.

Series applied, thank you.
