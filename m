From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] keep track of network interface renaming
Date: Wed, 16 Aug 2006 04:35:39 +0200
Message-ID: <44E2847B.7050909@trash.net>
References: <20060815165635.GA31291@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55207 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750833AbWHPCfm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 22:35:42 -0400
To: Olaf Hering <olaf@aepfle.de>
In-Reply-To: <20060815165635.GA31291@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Hering wrote:
> Keep track about which network interface names were renamed after the
> network device driver printed its banner. Previous kernel names will
> be reused when new interfaces get registerd.
> Recent udev scripts implement a stable kernel device name for network
> interfaces.
> This printk avoids confusion about what network hardware maps to what
> kernel interface in later driver or network stack messages.


I think it would be even easier to follow, especially with many devices,
if some stable identifier was included in messages relating to network
devices, like ifindex or maybe the LL address. And it would avoid
spamming the ringbuffer for people making use of this to implement
alternative naming schemes.


