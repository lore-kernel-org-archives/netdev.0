From: David Miller <davem@davemloft.net>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 12:25:42 -0500 (EST)
Message-ID: <20150113.122542.815831933030545121.davem@davemloft.net>
References: <54B50C71.7090007@miraclelinux.com>
	<1421152613.13626.24.camel@redhat.com>
	<54B53187.7080306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, hideaki.yoshifuji@miraclelinux.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbAMRZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:25:47 -0500
In-Reply-To: <54B53187.7080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 13 Jan 2015 07:53:59 -0700

> Bottom line is there a harm in removing the flush? If there is no harm
> will mainline kernel take a patch to do that or is your backward
> compatibility concern enough to block it?

Backward compatibility trumps all other concerns here, and I say is
enough to block changing the behavior.  One which we've had for more
than a decade.
