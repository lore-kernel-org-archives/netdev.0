From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: pull request: sfc-2.6 2010-12-07
Date: Tue, 07 Dec 2010 21:45:35 +0000
Message-ID: <1291758335.21627.22.camel@bwh-desktop>
References: <1291758047.21627.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42087 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab0LGVpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 16:45:38 -0500
In-Reply-To: <1291758047.21627.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-07 at 21:40 +0000, Ben Hutchings wrote:
> The following changes since commit 46bcf14f44d8f31ecfdc8b6708ec15a3b33316d9:
> 
>   filter: fix sk_filter rcu handling (2010-12-06 09:29:43 -0800)
> 
> are available in the git repository at:
>   git://git.kernel.org/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.37

That should of course be:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.37

Ben.

> (or will be shortly).
> 
> These fix bugs introduced in 2.6.37-rc1.  Please pull.
> 
> Ben.
> 
> Ben Hutchings (2):
>       sfc: Fix crash in legacy onterrupt handler during ring reallocation
>       sfc: Fix NAPI list corruption during ring reallocation
> 
>  drivers/net/sfc/efx.c        |   43 ++++++++++++++++++++++++++++-------------
>  drivers/net/sfc/net_driver.h |    2 +
>  drivers/net/sfc/nic.c        |    6 +++++
>  3 files changed, 37 insertions(+), 14 deletions(-)
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

