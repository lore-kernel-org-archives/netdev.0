From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove unnecessary include
Date: Mon, 17 Aug 2015 14:34:32 -0700 (PDT)
Message-ID: <20150817.143432.883151747269201704.davem@davemloft.net>
References: <1439590399-21374-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbbHQVed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:34:33 -0400
In-Reply-To: <1439590399-21374-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Fri, 14 Aug 2015 23:13:19 +0100

> printk.h does not need to be explicitly included as we include kernel.h
> which already called it.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>

We should not rely on such things and include explicitly the headers
that directly provide the interfaces we wish to use.

I'm not applying this, sorry.
