From: Patrick McHardy <kaber@trash.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Thu, 03 Dec 2009 14:55:18 +0100
Message-ID: <4B17C346.3000906@trash.net>
References: <1259585129.3992.13.camel@nienna.balabit>	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>	 <20091202.223117.228943068.davem@davemloft.net> <1259848398.3766.43.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hidden@balabit.hu,
	hidden@sch.bme.hu, aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106AbZLCNzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:55:14 -0500
In-Reply-To: <1259848398.3766.43.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> BTW, it should be noted that the change from Patrick to fib_validate
> which allows to accept local routes from will also solve this problem.
> My suggestion below is to restore old expected behavior..

Agreed, the accept_local sysctl should not be misused for this,
otherwise TPROXY setups wouldn't have source validation anymore.
