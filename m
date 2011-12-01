From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Thu, 01 Dec 2011 13:00:45 -0500 (EST)
Message-ID: <20111201.130045.2061330448127491799.davem@davemloft.net>
References: <20111129.124715.163094087536706067.davem@davemloft.net>
	<CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com>
	<20111201165018.GA19451@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: kirr@mns.spb.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab1LASA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 13:00:58 -0500
In-Reply-To: <20111201165018.GA19451@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kirill Smelkov <kirr@mns.spb.ru>
Date: Thu, 1 Dec 2011 20:50:18 +0400

> One "regression" is it is now not possible to disable BQL at compile time,
> because CONFIG_BQL can't be set to "n" via usual ways.
> 
> Description and patch below. Thanks.

It's intentional, and your patch will not be applied.

The Kconfig entry and option is merely for expressing internal dependencies,
not for providing a way to disable the code.
