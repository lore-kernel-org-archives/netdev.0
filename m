From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_v6_md5_do_lookup prototype
Date: Tue, 29 Sep 2015 21:33:34 -0700 (PDT)
Message-ID: <20150929.213334.1229387664061249438.davem@davemloft.net>
References: <1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150929.211243.946334552303109593.davem@davemloft.net>
	<1443587045.32531.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, edumazet@google.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbbI3Ede (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:33:34 -0400
In-Reply-To: <1443587045.32531.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Sep 2015 21:24:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_v6_md5_do_lookup() now takes a const socket, even if
> CONFIG_TCP_MD5SIG is not set.
> 
> Fixes: b83e3deb974c ("tcp: md5: constify tcp_md5_do_lookup() socket argument")
> From: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied, thanks Eric.
