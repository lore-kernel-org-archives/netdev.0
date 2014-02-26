From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ieee802154: fix new function declaration
Date: Wed, 26 Feb 2014 15:47:27 -0500 (EST)
Message-ID: <20140226.154727.892996164971237713.davem@davemloft.net>
References: <1393393109-11079-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbaBZUr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:47:29 -0500
In-Reply-To: <1393393109-11079-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Tue, 25 Feb 2014 22:38:29 -0700

> The commit 8fad346f366a7 ("eee802154: add basic support for RF212 to
> at86rf230 driver") introduced the new function is_rf212() with some
> minor issues in declaration:
> 
> 1) Fix the function type by changing it to bool as the function
>    definition returns a boolean value. Additionally both callers of
>    is_rf212() are expected to return a boolean value.
> 
> 2) Fix the function specifier by deleting the inline keyword as the
>    compiler takes care of that.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied, thanks.
