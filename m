From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge wake on lan failing
Date: Thu, 15 Jun 2006 14:38:43 -0700
Message-ID: <20060615143843.1dbf0255@dxpl.pdx.osdl.net>
References: <pan.2006.06.14.21.10.25.592167@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53131 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031457AbWFOVic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 17:38:32 -0400
To: Sitsofe Wheeler <sitsofe@yahoo.com>
In-Reply-To: <pan.2006.06.14.21.10.25.592167@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2006 22:10:26 +0100
Sitsofe Wheeler <sitsofe@yahoo.com> wrote:

> Hello,
> 
> We have a bunch of PCI D-Link System Inc DGE-530T Gigabit Ethernet cards
> which use the skge driver. However, the link light for a given card goes
> off at the switch during a suspend to ram or power down even though an
> "ethtool -s eth0 wol g" has been issued.
> 
> Can anyone shed any light on the problem?

The driver hasn't been tested with Wol. Since I can't get suspend to RAM
work on any of the systems with the board, it has been hard to test.
I'll get to it, but it hasn't been high priority.
