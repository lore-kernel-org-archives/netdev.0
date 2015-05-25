From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm:he - Do not initialise statics to 0.
Date: Mon, 25 May 2015 16:36:17 -0400 (EDT)
Message-ID: <20150525.163617.1172231502407784808.davem@davemloft.net>
References: <1432583633-5129-1-git-send-email-shailendra.capricorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shailendra.capricorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbEYUgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 16:36:18 -0400
In-Reply-To: <1432583633-5129-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shailendra Verma <shailendra.capricorn@gmail.com>
Date: Tue, 26 May 2015 01:23:53 +0530

> Static variables are initialised to 0 by GCC.
> Fixes the following checkpatch error:
> ERROR: do not initialise statics to 0 or NULL
> FILE: drivers/atm/he.c:120:
> static bool sdh = 0;
> 
> Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>

true is not necessarily '1' and false is not necessarily '0',
therefore the correct fix would be to assign 'false' to this variable.

Furthermore you've submitted this in such a way that it cannot be
applied alongside the other atm:he patch you submitted.

This is why when you submit multiple patches to the same file, you
must group them and submit them relative to eachother and in a
specific order.
