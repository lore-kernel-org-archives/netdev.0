From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2 v4] lib: Replace 16384 netlink buf size by
 macro
Date: Fri, 27 Feb 2015 12:38:31 -0500 (EST)
Message-ID: <20150227.123831.436431838595846209.davem@davemloft.net>
References: <1425018700-32725-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbbB0Rig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:38:36 -0500
In-Reply-To: <1425018700-32725-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>
Date: Fri, 27 Feb 2015 08:31:40 +0200

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Replaced hard coded 16384 netlink buffer size by NLBUF_SIZE,
> which can be overridden by -DNLBUF_SIZE.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I would like to know what problem is solved by changing this to
any other value?

And then I would like to know why other potential solutions to
this problem were not considered, such as making the buffer size
dynamic and run-time selectable, perhaps with a size choosen
in a manner to avoid whatever problem you hit with the current
size.
