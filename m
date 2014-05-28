From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Tue, 27 May 2014 19:37:37 -0700 (PDT)
Message-ID: <20140527.193737.22275611325169063.davem@davemloft.net>
References: <20140527.145403.1114311769956769966.davem@davemloft.net>
	<20140528014848.GB5830@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbaE1Chn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 22:37:43 -0400
In-Reply-To: <20140528014848.GB5830@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Wed, 28 May 2014 09:48:48 +0800

> I haven't done some backporting job before, so not sure how to and which
> attention I should pay.
> 
> I guess I should use this tree:
>      git://git.kernel.org/pub/scm/linux/kernel/git/jirislaby/linux-stable.git
> and apply it on tag v3.14.4?

That is Jiri's personal tree strictly for 3.12 -stable development.

The real -stable tree is at:

	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

And you should make versions for the most recent tags for 3.14, 3.10, 3.4,
and 3.2
