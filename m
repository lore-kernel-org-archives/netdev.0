From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: make some functions return void
Date: Tue, 17 Jun 2014 15:32:13 -0700 (PDT)
Message-ID: <20140617.153213.1886636168424874003.davem@davemloft.net>
References: <cover.1402926490.git.panweiping3@gmail.com>
	<cover.1402926490.git.panweiping3@gmail.com>
	<611ae0d4d819f57c4d0c67afa8ed58b16c7d102a.1402926490.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967195AbaFQWcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 18:32:14 -0400
In-Reply-To: <611ae0d4d819f57c4d0c67afa8ed58b16c7d102a.1402926490.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Mon, 16 Jun 2014 21:57:23 +0800

> dev_close_many(), __dev_close_many() and __dev_close() do not need to return a
> int, so make them return void, and modify __dev_change_flags() accordingly.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

I agree with other reviewers that this doesn't make much sense and it's
better to have the close functions have consistent return types.

I'm not applying this, sorry.
