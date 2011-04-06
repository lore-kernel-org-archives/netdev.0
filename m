From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 02/12] skge: implement set_phys_id
Date: Wed, 06 Apr 2011 14:37:49 -0700 (PDT)
Message-ID: <20110406.143749.184826938.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184501.450494215@linuxplumber.net>
	<1301957852.2935.54.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756899Ab1DFViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:38:25 -0400
In-Reply-To: <1301957852.2935.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 04 Apr 2011 23:57:32 +0100

> On Mon, 2011-04-04 at 11:43 -0700, Stephen Hemminger wrote:
>> -		ms -= BLINK_MS;
>> +	switch (state) {
>> +	case ETHTOOL_ID_ACTIVE:
>> +		return -1;
> [...]
> 
> Must be -EINVAL.

I took care of this when I applied Stephen's patch.
