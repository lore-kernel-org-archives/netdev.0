From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: stmmac: use msleep instead of udelay for gpio
 reset
Date: Tue, 21 Apr 2015 20:31:34 -0400 (EDT)
Message-ID: <20150421.203134.3443090203330589.davem@davemloft.net>
References: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
	<20150421.173540.1253961571051792975.davem@davemloft.net>
	<20150421231347.GA3392@panicking>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, festevam@gmail.com, netdev@vger.kernel.org
To: michael@amarulasolutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbbDVAbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:31:35 -0400
In-Reply-To: <20150421231347.GA3392@panicking>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Trimarchi <michael@amarulasolutions.com>
Date: Wed, 22 Apr 2015 01:13:47 +0200

> Hi
> 
> On Tue, Apr 21, 2015 at 05:35:40PM -0400, David Miller wrote:
>> From: Michael Trimarchi <michael@amarulasolutions.com>
>> Date: Tue, 21 Apr 2015 13:16:13 +0200
>> 
>> > -			udelay(data->delays[0]);
>>  ...
>> > +			msleep(max(1U, data->delays[0] / 1000));
>> 
>> That looks very ugly with that max() expression in there.
>>
> 
> Is fine for you a DIV_ROUND_UP?

Not inside of these simple msleep() calls, no.

How about adjusting the values either in the datastructure or
in local variables instead?  That wasn't so hard to come up
with now, was it?
