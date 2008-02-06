From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Wed, 6 Feb 2008 10:01:57 -0600
Message-ID: <20080206160157.GA18228@lixom.net>
References: <1202300519-7294-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:53685 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbYBFQAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 11:00:53 -0500
Content-Disposition: inline
In-Reply-To: <1202300519-7294-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 01:21:59PM +0100, Stefan Roese wrote:
> With the removal the the "rgmii-interface" device_type property from the
> dts files, the newemac driver needs an update to only rely on compatible
> property.

What about systems using an older dts, such as one kexec:ing from an
older kernel?

Just because the device tree source is distributed in the kernel tree
doesn't mean it can give up backwards compatibility.


-Olof

