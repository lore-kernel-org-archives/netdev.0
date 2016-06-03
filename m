From: David Miller <davem@davemloft.net>
Subject: Re: latest net-next does not build on sparc?
Date: Fri, 03 Jun 2016 19:20:48 -0400 (EDT)
Message-ID: <20160603.192048.1069869374683271001.davem@davemloft.net>
References: <20160603223925.GQ16616@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbcFCXUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:20:50 -0400
In-Reply-To: <20160603223925.GQ16616@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 3 Jun 2016 18:39:25 -0400

> Just pulled 4.7.0-rc1, and I find a build error
> 
> kernel/locking/rwsem.c: In function ?down_write_killable?:
> kernel/locking/rwsem.c:65: error: implicit declaration of function ?__down_write_killable?
> make[2]: *** [kernel/locking/rwsem.o] Error 1
> 
> I had to pull in this patch:
>   http://lkml.iu.edu/hypermail/linux/kernel/1602.3/04431.html
> to get it  to build- did I just miss something in my pull?

That change isn't even in Linus's tree.
