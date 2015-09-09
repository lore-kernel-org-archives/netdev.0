From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethoc: Remove unnecessary #ifdef CONFIG_OF
Date: Wed, 09 Sep 2015 14:16:23 -0700 (PDT)
Message-ID: <20150909.141623.993134949056069300.davem@davemloft.net>
References: <1441790669-18623-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755485AbbIIVQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:16:24 -0400
In-Reply-To: <1441790669-18623-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Sep 2015 11:24:29 +0200

> For !CONFIG_OF of_get_property() is defined to always return NULL. Thus
> there's no need to protect the call to of_get_property() with #ifdef
> CONFIG_OF.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
