From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Wake On Lan device semantics
Date: Fri, 3 Nov 2006 16:11:21 -0800
Message-ID: <20061103161121.7533b32c@freekitty>
References: <20061103152025.5d27bd8d@freekitty>
	<454BD5FD.2030502@pobox.com>
	<20061103.160230.71088561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49636 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932502AbWKDARA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 19:17:00 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061103.160230.71088561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 03 Nov 2006 16:02:30 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 03 Nov 2006 18:51:25 -0500
> 
> > The purpose of WOL is being able to turn on a system remotely, if it is 
> > in a power-off or sleep state.
> > 
> > So, if the system is -on- and the interface is down and/or driver is 
> > unloaded, are you saying WOL is a problem somehow?
> 
> Stephen is saying that if you down an interface, it should disable
> that WoL functionality.
> 
> I guess you can argue that, like IP addresses, this WoL thing is an
> attribute of the "system".

Looking harder. The semantic needs to be WOL is okay if driver is loaded
and device is up or down. But the default for WOL should be disabled until
enabled by ethtool (or parameter).

-- 
Stephen Hemminger <shemminger@osdl.org>
