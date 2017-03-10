From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] nfp: CRC32 RSS hash, port name reporting
 and misc fastpath cleanups
Date: Thu, 09 Mar 2017 16:41:05 -0800 (PST)
Message-ID: <20170309.164105.1098446021840134571.davem@davemloft.net>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdCJAlI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 19:41:08 -0500
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed,  8 Mar 2017 08:56:59 -0800

> This series adds support for CRC32 RSS hash function to kernel API
> of which NFP driver immediately makes use.  There is also a
> .ndo_get_phys_port_name() implementation conforming to switchdev 
> name format.  Small patch takes advantage of napi_complete_done()'s
> return code.  Simon provides a fix for potentially trusting values 
> returned from FW too much.
> 
> A handful of unassuming fast path adjustments is also thrown in to make
> the upcoming xdp_adjust_head() series easier to review.

Series applied, thanks.
