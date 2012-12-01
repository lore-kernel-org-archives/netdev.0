From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2012-12-01
Date: Sat, 01 Dec 2012 11:33:23 -0500 (EST)
Message-ID: <20121201.113323.892001865049602196.davem@davemloft.net>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab2LAQdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:33:25 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 1 Dec 2012 04:40:21 +0000

> The following changes since commit bb728820fe7c42fdb838ab2745fb5fe6b18b5ffa:
> 
>   core: make GRO methods static. (2012-11-29 13:18:32 -0500)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit b9cc977d9d4d1866ee83df38815f4b3b34d99dd9)
> 
> 1. More workarounds for TX queue flush failures that can occur during
>    interface reconfiguration.
> 2. Fix spurious failure of a firmware request running during a system
>    clock change, e.g. ntpd started at the same time as driver load.
> 3. Fix inconsistent statistics after a firmware upgrade.
> 4. Fix a variable (non-)initialisation in offline self-test that can
>    make it more disruptive than intended.
> 5. Fix a race that can (at least) cause an assertion failure.
> 6. Miscellaneous cleanup.

Pulled, thanks a lot Ben.

I just want to point out how much I like your commit messages,
your patches are trivial to review because of them.

Thanks again.
