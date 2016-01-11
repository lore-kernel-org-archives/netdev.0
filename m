From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4.4-rc8 0/7] isdn: eicon: Silence frame size warnings
Date: Sun, 10 Jan 2016 22:53:12 -0500 (EST)
Message-ID: <20160110.225312.2216480455312458141.davem@davemloft.net>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757949AbcAKDxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:53:14 -0500
In-Reply-To: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tim.gardner@canonical.com
Date: Fri,  8 Jan 2016 05:32:48 -0700

> Following is a patch set to recode various functions within the eicon driver in
> order to silence frame size warnings. The final patch consolidates some of this
> code into a single function which hopefully reduces complexity and the amount
> of code.

If you were just fixing one case of this I wouldn't be so strict but
the following, but because you are changing several such cases I am
going to be.

You have to add appropriate -ENOMEM error propragation and handling
into the callers of these functions.
