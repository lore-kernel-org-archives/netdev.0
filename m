From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] Fixes for the MV88e6xxx interrupt code
Date: Sun, 20 Nov 2016 21:16:35 -0500 (EST)
Message-ID: <20161120.211635.203786442457520502.davem@davemloft.net>
References: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbcKUCQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 21:16:42 -0500
In-Reply-To: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 20 Nov 2016 20:14:13 +0100

> The interrupt code was never tested with a board who's probing
> resulted in an -EPROBE_DEFFERED. So the clean up paths never got
> tested. I now do have -EPROBE_DEFFERED, and things break badly during
> cleanup. These are the fixes.
> 
> This is fixing code in net-next.
> 
> v2:
> Fix typo pointed out by David Miller

Series applied, thanks Andrew.
