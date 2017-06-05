From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Mon, 5 Jun 2017 23:26:17 +0200
Message-ID: <20170605212617.GC9339@lunn.ch>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Chris Blake <chrisrblake93@gmail.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37103 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751189AbdFEV0V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 17:26:21 -0400
Content-Disposition: inline
In-Reply-To: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In order to stay compatible with existing configurations, the
> driver will try the normal reset first and only falls back to
> to the internal clock, after the first reset fails. If the
> second reset fails as well, it will give up as before.

Hi Christian

This gets things probed correctly. But should you swap back to the PHY
clock when the PHY declares the link up? Is there code already to do
this?

	Andrew
