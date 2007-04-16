From: Matt Mackall <mpm@selenic.com>
Subject: Re: [BUG] netconsole hangs machine 2.6.20
Date: Mon, 16 Apr 2007 13:02:49 -0500
Message-ID: <20070416180249.GD11166@waste.org>
References: <20070415224537.2071da33@reforged>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Mike Mattie <codermattie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:47071 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145AbXDPSPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 14:15:19 -0400
Content-Disposition: inline
In-Reply-To: <20070415224537.2071da33@reforged>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[cc:ed to netdev]

On Sun, Apr 15, 2007 at 10:45:37PM -0700, Mike Mattie wrote:
> Hello,
> 
> netconsole is hanging my box during IDE init.
> 
> I am running 2.6.20.7, config is attached from /proc
> 
> Without using netconsole the kernel boots fine. I am writing this message from it. 
> 
> When I do enable net-console I get from the linux banner to a couple of lines after
> "sanitize end" on the logging client ( Mac OS X 10.4 , simple nc listener )
> 
> The boot continues until hde (handled by the HPT366 driver, hdg is the last drive )
> and then the kernel just hangs.

I don't really have a theory for that. What NIC are you using? Looks
like VIA Rhine? Is it sharing an IRQ with your IDE interface?

Please post your boot messages with "debug" on the kernel command
line.

-- 
Mathematics is the supreme nostalgia of our time.
