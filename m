From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Tue, 28 Jun 2011 13:31:08 -0700
Message-ID: <1309293068.29598.14.camel@Joe-Laptop>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	 <1309292501.2771.48.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3267 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1F1UbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 16:31:10 -0400
In-Reply-To: <1309292501.2771.48.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-28 at 21:21 +0100, Ben Hutchings wrote:
> On Tue, 2011-06-28 at 12:40 -0700, Joe Perches wrote:
> > Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> > Coalesce long formats.
> [...]
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -72,6 +72,8 @@
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> [...]
> KBUILD_MODNAME is presumably going to be "dev".

'tis.

> That's not very meaningful.

I think it's not useless though.

Anything else you think it should be?
Maybe "net_core_device:" or some such like that?

Here are the format strings now prefaced by "dev:"

$ strings net/core/built-in.o |grep "^<.>dev:"
<6>dev: netif_stop_queue() cannot be called before register_netdev()
<4>dev: dev_remove_pack: %p not found
<3>dev: Loading kernel module for a network device with CAP_SYS_MODULE (deprecated)
<0>dev: %s: failed to move %s to init_net: %d
<3>dev: alloc_netdev: Unable to allocate device with zero queues
<3>dev: alloc_netdev: Unable to allocate device with zero RX queues
<3>dev: alloc_netdev: Unable to allocate device



