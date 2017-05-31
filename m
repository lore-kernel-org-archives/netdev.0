From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next] nfp: add MAY_USE_DEVLINK dependency
Date: Wed, 31 May 2017 01:57:21 -0700
Message-ID: <20170531015721.7a6d230e@cakuba.lan>
References: <20170531081700.1948289-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        "David S. Miller" <davem@davemloft.net>, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:19342 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbdEaI53 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 04:57:29 -0400
In-Reply-To: <20170531081700.1948289-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 May 2017 10:16:50 +0200, Arnd Bergmann wrote:
> When devlink is configured as a loadable module, a built-in nfp driver
> causes a link error:
> 
> drivers/net/built-in.o: In function `nfp_devlink_port_register':
> (.text+0xb8b05): undefined reference to `devlink_port_type_eth_set'
> drivers/net/built-in.o: In function `nfp_devlink_port_register':
> (.text+0xb8b16): undefined reference to `devlink_port_split_set'
> 
> This adds a special Kconfig dependency on CONFIG_MAY_USE_DEVLINK
> to avoid that combination and force nfp to be a module when NET_DEVLINK=m.

Thanks, this should be fixed in net-next already by commit 
d935bc84c940 ("nfp: add MAY_USE_DEVLINK dependency").  Same 
subject/commit title as yours :)
