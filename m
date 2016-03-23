From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3] net: phy: at8030: Expose the Link and Activity LEDs
Date: Wed, 23 Mar 2016 19:56:28 +0100
Message-ID: <20160323185628.GN5250@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <1458755500-15571-3-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, ujhelyi.m@gmail.com, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55645 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbcCWS43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 14:56:29 -0400
Content-Disposition: inline
In-Reply-To: <1458755500-15571-3-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 06:51:39PM +0100, Vishal Thanki wrote:
> Expose these LEDs by means of a platform device which
> can be controlled by a suitable LED driver.

I would expose the leds directly here in this driver, not via a
separate platform device.

	 Andrew
