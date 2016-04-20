From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/ipv6/addrconf: simplify sysctl registration
Date: Tue, 19 Apr 2016 20:13:29 -0400 (EDT)
Message-ID: <20160419.201329.457243095977049352.davem@davemloft.net>
References: <146097967035.15409.8235893232862124602.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097967035.15409.8235893232862124602.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 18 Apr 2016 14:41:10 +0300

> Struct ctl_table_header holds pointer to sysctl table which could be used
> for freeing it after unregistration. IPv4 sysctls already use that.
> Remove redundant NULL assignment: ndev allocated using kzalloc.
> 
> This also saves some bytes: sysctl table could be shorter than
> DEVCONF_MAX+1 if some options are disable in config.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
