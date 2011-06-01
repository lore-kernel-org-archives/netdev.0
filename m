From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure
 counters
Date: Wed, 01 Jun 2011 12:22:40 -0700 (PDT)
Message-ID: <20110601.122240.1431839726613846748.davem@davemloft.net>
References: <16056.1306944819@death>
	<20110601.120300.130602301077156524.davem@davemloft.net>
	<4DE68ECB.70802@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, jpirko@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702Ab1FATWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 15:22:47 -0400
In-Reply-To: <4DE68ECB.70802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 01 Jun 2011 16:11:07 -0300

> On 06/01/2011 04:03 PM, David Miller wrote:
>> From: Jay Vosburgh <fubar@us.ibm.com>
>> Date: Wed, 01 Jun 2011 09:13:39 -0700
>> 
>>> 	The "this dingus was added in version X.Y.Z" is there because
>>> users sometimes read the most recent version of the documentation (that
>>> they get from the internet) and then would become confused when their
>>> older distro driver lacked some option described in the documentation.
>> 
>> I disagree with this whole concept, because distros backport features
>> like this into their kernel and therefore the feature is showing up in
>> version X.Y.$(Z-20).
> 
> It doesn't matter the version if the user can find the feature, so
> distros backporting features works and that info is not useful at all. 
> However, when the user doesn't find the feature and search the internet,
> then that info is helpful.

So how is the user going to find that FC14 has the feature even
though his FC13 kernel does not?

I'll say it again, this version stuff is completely pointless.

If the user is dabbling with upstream kernels he's a minority,
and clueful enough to figure out this stuff himself.

