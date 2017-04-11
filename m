From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 00/10] ftgmac100: Rework batch 4 - Misc
Date: Tue, 11 Apr 2017 11:08:15 +1000
Message-ID: <1491872895.4166.217.camel@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51496 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750761AbdDKBIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:08:25 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3B18FBA026514
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 20:08:17 -0500
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 11:04 +1000, Benjamin Herrenschmidt wrote:
> This is the fourth batch of updates to the ftgmac100 driver.
> 
> This is a bunch of misc cleanups and fixes, such as properly
> disabling HW checksum generation on AST2400 where it's known
> to be broken and some chip init updates.
> 
> This also adds the ability to turn HW checksum on/off and
> configure the ring sizes via ethtool.
> 
> The next (and last) batch will add a few more "features" such
> as netpoll, multicast/promist, vlan offload...

FYI. This series plays a bit with the device-tree properties for
this driver. There is more in the last batch, which will also
include an patch adding 

Documentation/devicetree/bindings/net/ftgmac100.txt

documenting all this.

Cheers,
Ben.
