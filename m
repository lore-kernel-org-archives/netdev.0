From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Wed, 29 Jun 2016 06:12:01 -0400 (EDT)
Message-ID: <20160629.061201.2186992042260603628.davem@davemloft.net>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
	<20160628010551.GD26597@lunn.ch>
	<CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbcF2KMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 06:12:32 -0400
In-Reply-To: <CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 27 Jun 2016 18:19:28 -0700

> 2016-06-27 18:05 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
>> On Mon, Jun 27, 2016 at 05:52:37PM -0700, Florian Fainelli wrote:
>>> Hi all,
>>>
>>> This patch series adds support for platform data using the new code from
>>> net/dsa/dsa2.c. The motivation behind this is that we have a bit of in tree
>>> platforms (ar7, bcm47xx, x86, others) that could be benefiting from the new
>>> dsa_register_switch() API model but do not support Device Tree, nor is there a
>>> plan to bring Device Tree to these platforms (time vs. benefits).
>>
>> Hi Florian
>>
>> Please could you convert an in tree device to actually use this.
> 
> Sure, I don't think there are going to be in tree users who need the
> dsa2_port_link information most of what we have is typically single
> chip, and so in that case, we can even re-use the existing
> dsa_platform_data.

I assume therefore that this series will be resubmitted with an
accompanying example in-tree conversion.
