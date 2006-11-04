From: David Miller <davem@davemloft.net>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 16:02:30 -0800 (PST)
Message-ID: <20061103.160230.71088561.davem@davemloft.net>
References: <20061103152025.5d27bd8d@freekitty>
	<454BD5FD.2030502@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42387
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932505AbWKDAC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 19:02:29 -0500
To: jgarzik@pobox.com
In-Reply-To: <454BD5FD.2030502@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 03 Nov 2006 18:51:25 -0500

> The purpose of WOL is being able to turn on a system remotely, if it is 
> in a power-off or sleep state.
> 
> So, if the system is -on- and the interface is down and/or driver is 
> unloaded, are you saying WOL is a problem somehow?

Stephen is saying that if you down an interface, it should disable
that WoL functionality.

I guess you can argue that, like IP addresses, this WoL thing is an
attribute of the "system".
