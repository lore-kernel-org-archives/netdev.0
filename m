From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] af_llc: fix types on llc_ui_wait_for_conn
Date: Wed, 17 Feb 2016 16:12:46 -0500 (EST)
Message-ID: <20160217.161246.355892499509813898.davem@davemloft.net>
References: <20160215194129.18888.95792.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965348AbcBQVMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:12:49 -0500
In-Reply-To: <20160215194129.18888.95792.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan <gnomes@lxorguk.ukuu.org.uk>
Date: Mon, 15 Feb 2016 19:41:51 +0000

> The timeout is a long, we return it truncated if it is huge. Basically
> harmless as the only caller does a boolean check, but tidy it up anyway.
> 
> (64bit build tested this time. Thank you 0day)
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied, thanks Alan.

Please take into consideration Simon's idea to change the return type to
bool as a follow-up.

Thanks.
