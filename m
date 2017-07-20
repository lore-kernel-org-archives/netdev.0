From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Enable CMODE config support for
 6390X
Date: Wed, 19 Jul 2017 22:26:39 -0700 (PDT)
Message-ID: <20170719.222639.581694657235005931.davem@davemloft.net>
References: <20170719061702.7692-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, andrew@lunn.ch
To: mnhu@prevas.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933072AbdGTF0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 01:26:40 -0400
In-Reply-To: <20170719061702.7692-1-mnhu@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Hundebøll <mnhu@prevas.dk>
Date: Wed, 19 Jul 2017 08:17:02 +0200

> Commit f39908d3b1c45 ('net: dsa: mv88e6xxx: Set the CMODE for mv88e6390
> ports 9 & 10') added support for setting the CMODE for the 6390X family,
> but only enabled it for 9290 and 6390 - and left out 6390X.
> 
> Fix support for setting the CMODE on 6390X also by assigning
> mv88e6390x_port_set_cmode() to the .port_set_cmode function pointer in
> mv88e6390x_ops too.
> 
> Signed-off-by: Martin Hundebøll <mnhu@prevas.dk>

Applied and queued up for -stable, thanks.
