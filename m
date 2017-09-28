From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: dsa: mv88e6xxx: Allow dsa and cpu ports in
 multiple vlans
Date: Thu, 28 Sep 2017 09:45:49 -0700 (PDT)
Message-ID: <20170928.094549.274076394145598600.davem@davemloft.net>
References: <1506375140-2853-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48652 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdI1Qpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:45:50 -0400
In-Reply-To: <1506375140-2853-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 25 Sep 2017 23:32:20 +0200

> Ports with the same VLAN must all be in the same bridge. However the
> CPU and DSA ports need to be in multiple VLANs spread over multiple
> bridges. So exclude them when performing this test.
> 
> Fixes: b2f81d304cee ("net: dsa: add CPU and DSA ports as VLAN members")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied and queued up for -stable, thanks.
