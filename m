From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 11:24:06 -0800 (PST)
Message-ID: <20150127.112406.159033030097516231.davem@davemloft.net>
References: <20150127.001226.711259930266409202.davem_()_davemloft_!_net>
	<1422349230-17394-1-git-send-email-fan.du@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@intel.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569AbbA0TYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:24:07 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 27 Jan 2015 09:46:21 +0000

> From: Fan Du
>> structure like xfrm_usersa_info or xfrm_userpolicy_info
>> has different sizeof when compiled as 32bits and 64bits
>> due to not appending pack attribute in their definition.
> 
> Don't 'pack' the structure, just ensure that all the fields
> are fixed sized and on their natural boundary.

This horse went out of the door more than a decade ago, we can't
change the layout of any of these structures and must at some point
add code to translate instead.
