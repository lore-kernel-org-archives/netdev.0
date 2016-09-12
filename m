From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: add FIB support
Date: Mon, 12 Sep 2016 16:00:02 +0200
Message-ID: <20160912140002.GH11400@lunn.ch>
References: <1473675233-36952-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41595 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757879AbcILOAH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 10:00:07 -0400
Content-Disposition: inline
In-Reply-To: <1473675233-36952-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John

> +	if (!ds->drv->ipv4_fib_prepare || !ds->drv->ipv4_fib_add)

drv recently got renamed to ops, which is what 0-day is complaining
about.

	Andrew
