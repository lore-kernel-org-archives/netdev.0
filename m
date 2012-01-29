From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next 2012-01-27
Date: Sun, 29 Jan 2012 16:18:20 -0500 (EST)
Message-ID: <20120129.161820.1090236443384833933.davem@davemloft.net>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab2A2VSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 16:18:24 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Jan 2012 20:40:58 +0000

> The following changes since commit 9b28ecd66b391349d3492574500f978566195454:
> 
>   net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devices (2012-01-25 16:59:47 -0500)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit db3395697cad6e9dff8d21249e0b59dc9bb83b48)
> 
> This is a mixture of cleanup, minor bug fixes, and a few features:
> 
> - Increase default number of queues to 1 per core
> - Add hardware monitor driver for Siena

Pulled, but two things:

1) Please address Joe Perches's feedback, with follow-on patches
   if necessary.

2) That DEBUG undef for the sake of mtd.h has to go, I see no use
   nor even a reference to DEBUG in that header file in the current
   sources.

Thanks.
