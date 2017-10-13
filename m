From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: support bgmac with B50212E B1 PHY
Date: Thu, 12 Oct 2017 22:59:55 -0700 (PDT)
Message-ID: <20171012.225955.1962625502192879577.davem@davemloft.net>
References: <20171012082126.30660-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        hauke@hauke-m.de, jon.mason@broadcom.com, steven.lin1@broadcom.com,
        tklauser@distanz.ch, bcm-kernel-feedback-list@broadcom.com,
        rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753271AbdJMF75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 01:59:57 -0400
In-Reply-To: <20171012082126.30660-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Thu, 12 Oct 2017 10:21:24 +0200

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> I got a report that a board with BCM47189 SoC and B50212E B1 PHY doesn't
> work well some devices as there is massive ping loss. After analyzing
> PHY state it has appeared that is runs in slave mode and doesn't auto
> switch to master properly when needed.
> 
> This patchset fixes this by:
> 1) Adding new flag support to the PHY driver for setting master mode
> 2) Modifying bgmac to request master mode for reported hardware

Series applied to net-next, thanks.
