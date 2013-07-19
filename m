From: David Miller <davem@davemloft.net>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Thu, 18 Jul 2013 20:31:00 -0700 (PDT)
Message-ID: <20130718.203100.1960741588589171145.davem@davemloft.net>
References: <51E881EB.5040600@windriver.com>
	<20130718.201801.1591610112107900505.davem@davemloft.net>
	<51E8B273.1090002@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182Ab3GSDbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 23:31:01 -0400
In-Reply-To: <51E8B273.1090002@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 19 Jul 2013 11:28:51 +0800

> On 2013年07月19日 11:18, David Miller wrote:
>> Although it's a correct change, it is of almost no value.  %99.9999999
>> of users will be running kernels with CONFIG_XFRM enabled.
> 
> Thanks. Good to know %99.99999999 users protect their networking with
> IPsec.

That is not what I said.

I said that nearly every user will be running a kernel with that
config option enabled, I did not say that they will actually be
using IPSEC.

Distributions enable all options, so that users may use any facility
that they want.

So optimizing for things like this are almost pointless.
