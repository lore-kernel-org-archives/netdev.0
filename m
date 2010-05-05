From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [RFC PATCH net-next] drivers/net/ks*: Use netdev_<level>, netif_<level> and pr_<level>
Date: Wed, 5 May 2010 10:06:15 -0700
Message-ID: <14385191E87B904DBD836449AA30269D6DE843@MORGANITE.micrel.com>
References: <1267317831.30706.26.camel@Joe-Laptop.home> <20100316.213133.102673436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ben@simtec.co.uk>, "Choi, David" <David.Choi@Micrel.Com>,
	<richard.rojfors.ext@mocean-labs.com>, <netdev@vger.kernel.org>,
	<joe@perches.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o142.mxlogic.net ([208.65.144.65]:43039 "EHLO
	p01c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab0EERG7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 13:06:59 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100316.213133.102673436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sat, 27 Feb 2010 16:43:51 -0800
> 
>> I'm not sure this is correct.
>> 
>> It changes logging macros from:
>> 	dev_<level>(&ks->spidev->dev,
>> to
>> 	netdev_<level>(ks->netdev,
> 
> I'm just applying this, more than a week to get a review is more than
enough.
> 
> Thanks Joe.

I have no objection about the patch as it just uses the latest kernel
debug call.  Is this new code available in current 2.6.34 release?  Or
will it be in the next version?

I generally download the latest 2.6.34-rc release to generate patches
for submission.
