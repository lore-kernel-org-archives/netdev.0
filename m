From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 14 Jun 2016 19:23:04 +0200
Message-ID: <20160614172304.GB4914@lunn.ch>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
 <201606141828.10969@pali>
 <20160614164017.GB14477@kroah.com>
 <201606141847.36109@pali>
 <ba393fe424fd4a8fb82703dd0f42eea7@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pali.rohar@gmail.com, gregkh@linuxfoundation.org,
	davem@davemloft.net, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45405 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbcFNRXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 13:23:14 -0400
Content-Disposition: inline
In-Reply-To: <ba393fe424fd4a8fb82703dd0f42eea7@ausx13mpc124.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > It is same, how to handle two network cards which tell us, that they
> > have same MAC addresses.
> > 
> 
> The kernel handles this just fine.  In doing this patch I checked to see
> what it does in that scenario.  Two devices are made.  systemd doesn't
> rename the second device via the MAC name (eg enxAABBCCDDEEFF).

What does you dhcp server do? Does it gives out the same IP address?
You then have two interfaces on the same network, with the same MAC
address and IP address. Then what happens?

     Andrew
