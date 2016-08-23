From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix MV88E6131 tagging
Date: Mon, 22 Aug 2016 21:08:54 -0700 (PDT)
Message-ID: <20160822.210854.2222713381334094120.davem@davemloft.net>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jm@lentin.co.uk, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbcHWEIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 00:08:55 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 22 Aug 2016 16:01:00 +0200

> Marvell has two different tagging protocols for frames passed to a
> swicth. There is the older DSA and the newer EDSA. Somewhere along the
> way, we broke support for switches which only support DSA, by trying
> to configure them to use EDSA. These patches add back support for
> switches which only support DSA, by allowing the drivers to
> dynamically indicate the tagging protocol they support to the DSA
> core. This needs to be dynamic since the mv88e6xxx has to support two
> protocols.
> 
> Thanks go to Jamie Lentin for reporting the problem, helping debug it,
> providing some of the fix, and testing.

Series applied, thanks.

As per tree-wide policy, when a driver unloads the device should be
disabled and in fact if possible configured to not draw power.
