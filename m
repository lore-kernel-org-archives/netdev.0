From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] nfp: bpf ABIv2 and multi port
Date: Mon, 09 Oct 2017 09:52:03 -0700 (PDT)
Message-ID: <20171009.095203.1106666816137564253.davem@davemloft.net>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdJIQwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:52:08 -0400
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun,  8 Oct 2017 21:04:02 -0700

> This series migrates our eBPF offload from old PoC firmware to 
> a redesigned, faster and more feature rich FW.  Marking support
> is dropped for now.  We have to teach the JIT about encoding
> local memory accesses (one of NFP memory types).  There is also
> code to populate the ECC of instructions (PoC had ECC protection
> on instruction store disabled).  There is also a minor ld_field
> fix and all 64 bit shifts can now be encoded.

Thank you for structuring this series the way you did, as this made it
very easy to review.

Series applied.
