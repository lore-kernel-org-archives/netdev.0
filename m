From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this
 into a library module
Date: Thu, 14 Apr 2016 17:49:51 -0400 (EDT)
Message-ID: <20160414.174951.1036895874300851739.davem@davemloft.net>
References: <1460591998-20598-2-git-send-email-andrew@lunn.ch>
	<874mb454b3.fsf@ketchup.mtl.sfl>
	<57100B0F.4040909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbcDNVtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 17:49:55 -0400
In-Reply-To: <57100B0F.4040909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 14 Apr 2016 14:26:39 -0700

> On 14/04/16 13:22, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>>> Export all the functions so that we can later turn the module into a
>>> library module.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>> 
>> Sorry but I don't like this. We don't want one module per 88E6xxx switch
>> model. We need one driver supporting them all, like any other driver.
> 
> Are you sure this is a good model moving forward? This means the library
> needs to know about every new switch added and all its little gory
> details, whereas the point is that it represents *most* of what is
> needed, defines a good enough, generic model, but does not have to deal
> (too much) with HW-specifics, see below.

I also think all of the mv88e6xxx drivers are insanely similar, and could
be driven by one monolithic driver.  It's not going to be that big at all.

Symbol exporting from a library and having several small similar
drivers reference those symbols, on the other hand, tends to be messy
in my opinion.
