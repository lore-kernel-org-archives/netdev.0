From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] nfp: RX and XDP buffer fixes
Date: Fri, 03 Mar 2017 09:48:31 -0800 (PST)
Message-ID: <20170303.094831.1587696881012463788.davem@davemloft.net>
References: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kubakici@wp.pl, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbdCCRtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 12:49:53 -0500
In-Reply-To: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu,  2 Mar 2017 15:26:19 -0800

> Two trivial fixes for code introduced with XDP support.  First
> one corrects the buffer size we populate a register with.  The
> register is designed to be used for scatter transfers which 
> the driver (and most FWs) don't support so it's not critical.
> The other one for DMA direction is mostly cosmetic, DMA API
> doesn't seem to care today about the precise direction in sync
> calls.

Series applied.
