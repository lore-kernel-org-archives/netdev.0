From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] ipv6: handle the update of the NDISC_REDIRECT error
 code in icmpv6_err_convert
Date: Thu, 19 Sep 2013 14:02:49 -0400 (EDT)
Message-ID: <20130919.140249.933962101950748423.davem@davemloft.net>
References: <523996E0.9080702@cn.fujitsu.com>
	<20130918.123613.61436246160249555.davem@davemloft.net>
	<523A8A74.30005@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3ISSCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:02:51 -0400
In-Reply-To: <523A8A74.30005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Thu, 19 Sep 2013 13:24:04 +0800

> 于 2013/9/19 0:36, David Miller 写道:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> Date: Wed, 18 Sep 2013 20:04:48 +0800
>>
>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>
>>> when dealing with redirect message in udpv6_err() and
>>> rawv6_err() the err shoud be assigned to 0, not EPROTO.
>>>
>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> No, you should fix this the same way you handled DCCP, but skipping
>> the whole socket error setting path for NDISC_REDIRECT.
> 
> Your meaning is that we should return directly after calling
> ip6_sk_redirect(), is that it?

It depends upon whether udp/raw sockets are expected to receive redirect
notifications this way, are they?  You seem to believe so.
