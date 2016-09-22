From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/2] Preparation for mv88e6390
Date: Thu, 22 Sep 2016 02:20:37 -0400 (EDT)
Message-ID: <20160922.022037.2027131263572505991.davem@davemloft.net>
References: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932749AbcIVGUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:20:40 -0400
In-Reply-To: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 21 Sep 2016 01:40:30 +0200

> These two patches are a couple of preparation steps for supporting the
> the MV88E6390 family of chips. This is a new generation from Marvell,
> and will need more feature flags than are currently available in an
> unsigned long. Expand to an unsigned long long. The MV88E6390 also
> places its port registers somewhere else, so add a wrapper around port
> register access.
> 
> v2:
>  Rework wrappers to use mv88e6xxx_{read|write}
>  Simpliy some (err < ) to (err)
> Add Reviewed by tag.
> 
> v3::
>  reg = reg & foo -> reg &= foo
>  Fix over zealous s/ret/err

Series applied, thanks.
