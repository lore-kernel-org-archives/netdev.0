From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Sun, 11 Nov 2012 17:02:47 -0500 (EST)
Message-ID: <20121111.170247.780516266044882867.davem@davemloft.net>
References: <1352668801-14373-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab2KKWCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:02:52 -0500
In-Reply-To: <1352668801-14373-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This code is a fast bit test on purpose.  You're making the
code slower.

I'm not applying this patch.
