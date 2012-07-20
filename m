From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: add support for wake-on-packet
Date: Fri, 20 Jul 2012 11:22:13 -0700 (PDT)
Message-ID: <20120720.112213.1696121870344034064.davem@davemloft.net>
References: <1342788723-27703-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com,
	linux-kernel@vger.kernel.org, leoli@freescale.com
To: chenhui.zhao@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab2GTSWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:22:15 -0400
In-Reply-To: <1342788723-27703-1-git-send-email-chenhui.zhao@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhao Chenhui <chenhui.zhao@freescale.com>
Date: Fri, 20 Jul 2012 20:52:03 +0800

> Note: The local ip/mac address is the ethernet primary IP/MAC address of
> the station. Do not support multiple IP/MAC addresses.

I'm not applying this.

There is no such concept of "primary IP address" for interfaces,
just picking the first interface address you find is completel
bogus.

Someone might add 100 IP addresses, then the one that's "primary",
and vice versa.
