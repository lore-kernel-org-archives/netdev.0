From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Restore UFO support to virtio_net devices
Date: Sun, 01 Feb 2015 22:28:34 -0800 (PST)
Message-ID: <20150201.222834.1543634857152757099.davem@davemloft.net>
References: <1422646047-13168-1-git-send-email-vyasevic@redhat.com>
	<20150201.221935.283572621026340671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com, ben@decadent.org.uk, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199AbbBBG2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:28:35 -0500
In-Reply-To: <20150201.221935.283572621026340671.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 01 Feb 2015 22:19:35 -0800 (PST)

> Series applied and queued up for -stable.

I have to revert, this breaks the build.

net/built-in.o: In function `udp6_ufo_fragment':
udp_offload.c:(.text+0x103380): undefined reference to `ipv6_select_ident'
