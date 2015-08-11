From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Tue, 11 Aug 2015 12:00:27 -0700 (PDT)
Message-ID: <20150811.120027.1186256660854311012.davem@davemloft.net>
References: <20150811.110708.2068514265578197752.davem@davemloft.net>
	<1084602462.1280363.1439317122548.JavaMail.zimbra@savoirfairelinux.com>
	<20150811.115249.1843804028134252781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	linux@roeck-us.net, andrew@lunn.ch, sfeldma@gmail.com,
	jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbbHKTA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 15:00:28 -0400
In-Reply-To: <20150811.115249.1843804028134252781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 11 Aug 2015 11:52:49 -0700 (PDT)

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Tue, 11 Aug 2015 14:18:42 -0400 (EDT)
> 
>> On Aug 11, 2015, at 2:07 PM, David davem@davemloft.net wrote:
>> 
>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>> Date: Tue, 11 Aug 2015 11:03:35 -0700
>>> 
>>>> Put differently, my question is how do you value not rewriting
>>>> history vs. breaking bisectability (by accident of course)?
>>> 
>>> I never will rewrite history, ever.
>>> 
>>> Too many people clone my tree and depend upon it.
>> 
>> Sorry, I still don't understand. What are the consequences of:
>> 
>>     git revert -m 1 f1d5ca4
>> 
>> Then applying v3?
> 
> In this scenerio I think a relative fixup works better.
> 
>> You already did that in the past:
>> https://github.com/torvalds/linux/commit/1f2cd84
> 
> Each and every situation is evaluated by me on a case by case
> basis.

Ok, if you guys really want me to I'll do the revert-reapply thing.
