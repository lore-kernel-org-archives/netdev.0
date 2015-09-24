From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: Reduce log level in ip6_tnl_err() to debug
Date: Thu, 24 Sep 2015 16:08:49 -0700 (PDT)
Message-ID: <20150924.160849.785863219643227629.davem@davemloft.net>
References: <1443135707-14620-1-git-send-email-matt.bennett@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, trivial@kernel.org
To: matt.bennett@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbbIXXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 19:08:50 -0400
In-Reply-To: <1443135707-14620-1-git-send-email-matt.bennett@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Bennett <matt.bennett@alliedtelesis.co.nz>
Date: Fri, 25 Sep 2015 11:01:47 +1200

> Currently error log messages in ip6_tnl_err are printed at 'warn'
> level. This is different to other tunnel types which don't print
> any messages. These log messages don't provide any information that
> couldn't be deduced with networking tools. Also it can be annoying
> to have one end of the tunnel go down and have the logs fill with
> pointless messages such as "Path to destination invalid or inactive!".
> 
> This patch reduces the log level of these messages to 'dbg' level to
> bring the visible behaviour into line with other tunnel types.
> 
> Signed-off-by: Matt Bennett <matt.bennett@alliedtelesis.co.nz>

Applied, thanks.
