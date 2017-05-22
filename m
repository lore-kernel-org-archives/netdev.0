From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 23:32:06 +0200
Message-ID: <20170522213206.GT29447@lunn.ch>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40397 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934250AbdEVVcH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:32:07 -0400
Content-Disposition: inline
In-Reply-To: <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'll have to test this, but what do I do if I don't get another interrupt?

It probably means interrupts cannot be used. Poll it.

	   Andrew
