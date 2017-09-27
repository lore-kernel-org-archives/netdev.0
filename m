From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] net: dsa: mv88e6xxx: Forward broadcast frames to
 cpu and dsa ports
Date: Tue, 26 Sep 2017 20:20:21 -0700 (PDT)
Message-ID: <20170926.202021.1637296078204678176.davem@davemloft.net>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
        <1506464764-12699-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031618AbdI0DUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 23:20:22 -0400
In-Reply-To: <1506464764-12699-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 27 Sep 2017 00:26:04 +0200

> +
> +	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {

Just a nit pick since you are going to respin this anyways:

	for (x; cond(x); x++)

seems to be the canonical way to express this in the kernel, so please
make "++port" into "port++"

Thank you.
