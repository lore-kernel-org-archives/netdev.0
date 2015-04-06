From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] bonding: LACP state machine variable
 "port-moved" is never set
Date: Mon, 06 Apr 2015 17:01:58 -0400 (EDT)
Message-ID: <20150406.170158.894434269756337066.davem@davemloft.net>
References: <1428094450-9308-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbbDFVCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:02:01 -0400
In-Reply-To: <1428094450-9308-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Fri,  3 Apr 2015 13:54:10 -0700

> The state-machine checks for the presence of this flag and attempts
> to clear it but the value is never set. So why have it?
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This commit log message doesn't sound like you are asserting that this
adjustment should made.

It sounds more like you actually aren't really sure, and you're asking
folks on the list what the intent of this code is.

I'm not applying this until the commit log is adjusted to show that
you are absolutely certain that this change is valid.
