From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 10:45:39 -0400 (EDT)
Message-ID: <20150512.104539.1602376250460164798.davem@davemloft.net>
References: <87383633pu.fsf_-_@x220.int.ebiederm.org>
	<87oalu1p16.fsf_-_@x220.int.ebiederm.org>
	<063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, cwang@twopensource.com, xemul@openvz.org,
	eric.dumazet@gmail.com, maxk@qti.qualcomm.com,
	stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	herbert@gondor.apana.org.au
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932507AbbELOpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:45:43 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 12 May 2015 08:24:11 +0000

> Changing the function prototype will a PITA for anyone doing back-ports of fixes.
> (And more so for anyone trying to get a driver to build against kernels
> that might have this change back-ported.)

As someone who actually does such backports every week or two for up
to 5 different -stable releases, I really don't find it to be a big
deal, and I've therefore developed a very low level of sympathy for
this argument so please don't make it as a reason to not make an
interface change.

Thanks.
