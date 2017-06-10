From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Sat, 10 Jun 2017 17:27:41 +0200
Message-ID: <20170610152741.GB26740@lunn.ch>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
To: crow <crow@linux.org.ba>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44177 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752004AbdFJP1q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 11:27:46 -0400
Content-Disposition: inline
In-Reply-To: <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also what Martin Blumenstingl wrote is following which is also crucial
> for fixing the issue:
> Amlogic has given their ethernet PHY driver some updates [2], it now
> includes wake-on-lan, and they now have an internal_phy_read_status
> which uses reset_internal_phy if there's a link and some error counter
> exceeds some magic value.

Hi Crow

You could probably just drop the Amlogic driver into mainline and see
if it works better. If that solves your problem, we can look at
merging the changes.

	Andrew
