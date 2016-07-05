From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/4] net: dsa: Suffix function manipulating
 device_node with _dn
Date: Wed, 6 Jul 2016 00:36:12 +0200
Message-ID: <20160705223612.GC28825@lunn.ch>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36514 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbcGEWgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 18:36:15 -0400
Content-Disposition: inline
In-Reply-To: <1467756433-25062-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 03:07:12PM -0700, Florian Fainelli wrote:
> Make it clear that these functions take a device_node structure pointer

Hi Florian

Didn't we agree that we would only support a single device via a C
coded platform data structure?

All the functions you are renaming will never be called in that
case. So i think they can retain there names. You have no need to add
none device node equivalents.

So lets drop this patch.

   Andrew
