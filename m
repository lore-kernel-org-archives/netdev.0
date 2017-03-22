From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] nfp: allow concurrency in core and
 minor fixes
Date: Wed, 22 Mar 2017 13:02:20 -0700 (PDT)
Message-ID: <20170322.130220.989621142548715686.davem@davemloft.net>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com, kubakici@wp.pl
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdCVUCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 16:02:22 -0400
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 21 Mar 2017 17:59:06 -0700

> The first 10 patches of this series prepare nfpcore for concurrent 
> accesses.  This will be needed by upcoming hwmon and devlink patches.
> Most locking is already in place, the patches in this series iron out
> a few bugs.
> 
> Last 5 patches are fixes and cleanups to the netdev code, including
> removal of doorbell pointers used only on old versions of the chip,
> removal of unnecessarily defensive code and flushing xmit_more more
> carefully on error paths.

Series applied, thank you.
