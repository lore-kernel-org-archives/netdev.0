From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5 0/3] net: libphy: Add phy specific functions to
 access mmd regs
Date: Wed, 30 Jul 2014 20:00:47 -0700 (PDT)
Message-ID: <20140730.200047.853167282063603089.davem@davemloft.net>
References: <1406665199-18174-1-git-send-email-vbridgers2013@gmail.com>
	<CAGVrzcYpYQAXOJMCuEdG0Yi9BiYVTUgQxehACYN=5LdZN21fQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridgers2013@gmail.com, rdunlap@infradead.org,
	netdev@vger.kernel.org, vbridger@altera.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477AbaGaDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 23:00:48 -0400
In-Reply-To: <CAGVrzcYpYQAXOJMCuEdG0Yi9BiYVTUgQxehACYN=5LdZN21fQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Jul 2014 14:29:53 -0700

> 2014-07-29 13:19 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
>> This set of patches addresses a problem found with the Micrel ksz9021 phy and
>> libphy, where the ksz9021 phy does not support mmd extended register access
>> per the IEEE specification as assumed by libphy. The first patch adds a
>> framework for phy specific support to specify their own function to access
>> extended phy registers, return a failure code if not supported, or to default
>> to libphy's IEEE defined method for accessing the mmd extended phy registers.
>>
>> This issue was found by using the Synopsys EMAC and a Micrel ksz9021 phy on the
>> Altera Cyclone 5 SOC development kit. This patch was tested on the same system
>> in both positive and negative test cases.
> 
> Thanks for putting this together, this looks good to me now!

Series applied to net-next, thanks everyone.
