From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] nfp: XDP adjust head support
Date: Sun, 12 Mar 2017 23:43:35 -0700 (PDT)
Message-ID: <20170312.234335.1328185272205305351.davem@davemloft.net>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com, kubakici@wp.pl
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54142 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751145AbdCMGng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:43:36 -0400
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 10 Mar 2017 10:38:26 -0800

> This series adds support for XDP adjust head.  Bulk of the code
> is actually just paying technical debt.  On reconfiguration request
> nfp was allocating new resources separately leaving device running
> with the existing set of rings.  We used to manage the new resources
> in special ring set structures.  This set is simply separating the
> datapath part of the device structure from the control information
> allowing the new datapath structure to be allocated with all new
> memory and rings.  The swap operation is now greatly simplified.
> We also save a lot of parameter passing this way.  Hopefully the churn
> is worth the negative diffstat.
> 
> Support for XDP adjust head is done in a pretty standard way.  NFP
> is a bit special because it prepends metadata before packet data
> so we have to do a bit of memcpying in case XDP will run.  We also
> luck out a little bit because the fact that we already have prepend
> space allocated means that one byte is enough to store the extra XDP
> space (256 of standard prepend space is a bit inconvenient since
> it would normally require 16bits or boolean with additional shifts).

Series applied, thanks.
