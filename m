From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: drivers/net/hippi/Kconfig should be sourced
Date: Wed, 09 Nov 2011 15:46:43 -0500 (EST)
Message-ID: <20111109.154643.2008804116058722848.davem@davemloft.net>
References: <1320784270.14409.404.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab1KIUqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:46:49 -0500
In-Reply-To: <1320784270.14409.404.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 08 Nov 2011 21:31:10 +0100

> Commit ff5a3b509e ("hippi: Move the HIPPI driver") moved the HIPPI
> driver into drivers/net/hippi. It didn't source
> drivers/net/hippi/Kconfig though, so it didn't make all necessary
> Kconfig changes. So let drivers/net/kconfig source HIPPI's Kconfig file.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> git grep tested only. Perhaps the exact spot where
> drivers/net/hippi/Kconfig gets sourced is relevant, so this needs
> (build) testing by people actually familiar with the HIPPI driver. 

Please at least type "make oldconfig" with CONFIG_HIPPI enabled or
similar before submitting patches like this.

There is nothing architecture or platform specific about getting
the option enabled enough for you to see this:

drivers/net/hippi/Kconfig:40: syntax error
drivers/net/hippi/Kconfig:20: missing end statement for this entry
drivers/net/Kconfig:28: missing end statement for this entry
drivers/Kconfig:1: missing end statement for this entry
drivers/net/hippi/Kconfig:39: invalid statement
drivers/net/Kconfig:341: unexpected end statement
drivers/Kconfig:139: unexpected end statement
make[1]: *** [oldconfig] Error 1
make: *** [oldconfig] Error 2

I've fixed this up but if you can't be bothered to type "make" I
seriously can't be bothered to even look at your patch submissions.
