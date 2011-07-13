From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] slip: remove dead code within the slip
 initialization
Date: Wed, 13 Jul 2011 02:32:42 -0700 (PDT)
Message-ID: <20110713.023242.858769644416598710.davem@davemloft.net>
References: <CAKh5naaqpjwaUUwJEkpN4g9iyQeUtZFn+XnCED4R=Ovo_hJ59A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965169Ab1GMJco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 05:32:44 -0400
In-Reply-To: <CAKh5naaqpjwaUUwJEkpN4g9iyQeUtZFn+XnCED4R=Ovo_hJ59A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Wed, 13 Jul 2011 11:47:38 +0400

> This following code contains a dead "if (dev).." block:
...
> The reason is that the code starting with "if (dev).." is never called as
> when we found an empty slot (dev == NULL) we break the loop and "if (dev).."
> not works eiter the loop ends and we get out with "i >= slip_maxdev".
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>

Applied.
