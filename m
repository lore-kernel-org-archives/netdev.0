From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: fix wrong ping_v6_sendmsg return value
Date: Wed, 03 Jul 2013 17:42:17 -0700 (PDT)
Message-ID: <20130703.174217.221167923506616123.davem@davemloft.net>
References: <1372864360-9450-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3GDAmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 20:42:21 -0400
In-Reply-To: <1372864360-9450-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu,  4 Jul 2013 00:12:40 +0900

> ping_v6_sendmsg currently returns 0 on success. It should return
> the number of bytes written instead.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
