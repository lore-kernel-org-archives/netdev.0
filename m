From: David Miller <davem@davemloft.net>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Wed, 14 Nov 2012 16:29:56 -0500 (EST)
Message-ID: <20121114.162956.610530798200803185.davem@davemloft.net>
References: <20121114231411.4328fc47@lola.kot>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kargig@void.gr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933092Ab2KNVaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 16:30:01 -0500
In-Reply-To: <20121114231411.4328fc47@lola.kot>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: George Kargiotakis <kargig@void.gr>
Date: Wed, 14 Nov 2012 23:14:11 +0200

> Due to the way the Linux kernel handles the creation of IPv6 temporary
> addresses a malicious LAN user can remotely disable them altogether
> which may lead to privacy violations and information disclosure.

A malicious user who can emit random packets as root on your LAN can
also corrupt your ARP cache with entries that point to the wrong MAC
address.

What's your point?
