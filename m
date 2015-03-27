From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 00/16] net: dsa: HW bridging, EEE support
Date: Fri, 27 Mar 2015 16:54:16 +0100
Message-ID: <20150327155416.GE11975@lunn.ch>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58499 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbbC0P6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 11:58:04 -0400
Content-Disposition: inline
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 06:36:27PM -0700, Guenter Roeck wrote:
> Patch 1 to 7 of this series prepare the drivers using the mv88e6xxx code
> for HW bridging support, without adding the code itself. For the most part
> this factors out common port initialization code. There is no functional
> change except for patch 3, which disables the message port bit for the
> CPU port to prevent packet duplication if HW bridging is configured.

I just re-tested on my WRT1900AC and 370RD. All looks good.

  Andrew
