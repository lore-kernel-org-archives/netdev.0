From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_gre: Reduce log level in ip6gre_err() to debug
Date: Thu, 24 Sep 2015 15:29:14 -0700 (PDT)
Message-ID: <20150924.152914.68429572387880625.davem@davemloft.net>
References: <1442984311-13668-1-git-send-email-matt.bennett@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, trivial@kernel.org
To: matt.bennett@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbbIXW3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:29:16 -0400
In-Reply-To: <1442984311-13668-1-git-send-email-matt.bennett@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Bennett <matt.bennett@alliedtelesis.co.nz>
Date: Wed, 23 Sep 2015 16:58:31 +1200

> Currently error log messages in ip6gre_err are printed at 'warn'
> level. This is different to most other tunnel types which don't
> print any messages. These log messages don't provide any information
> that couldn't be deduced with networking tools. Also it can be annoying
> to have one end of the tunnel go down and have the logs fill with
> pointless messages such as "Path to destination invalid or inactive!".
> 
> This patch reduces the log level of these messages to 'dbg' level to
> bring the visible behaviour into line with other tunnel types.
> 
> Signed-off-by: Matt Bennett <matt.bennett@alliedtelesis.co.nz>

Applied.

net/ipv6/ip6_tunnel.c, which is probably where this code was mostly
copy and pasted from, has the same issue.  Could you please take
care of that too?

Thanks.
