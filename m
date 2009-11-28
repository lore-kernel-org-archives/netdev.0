From: David Miller <davem@davemloft.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 13:21:58 -0800 (PST)
Message-ID: <20091128.132158.34557470.davem@davemloft.net>
References: <1259429774.3864.41.camel@bigi>
	<20091128190500.GB12264@sch.bme.hu>
	<1259437442.3864.61.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, hidden@balabit.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754099AbZK1VVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 16:21:52 -0500
In-Reply-To: <1259437442.3864.61.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sat, 28 Nov 2009 14:44:02 -0500

> On Sat, 2009-11-28 at 20:05 +0100, KOVACS Krisztian wrote:
>> Well, it depends whether or not you consider the initial setup valid.
>> 
> 
> Based on what i see - I frankly dont. If i looked up the source address

What matters is that this worked for years and we broke it.

There is no other valid discussion about this.

The only thing to "pick" right now is whether we revert the
thing completely or add a sysctl and default it to off.

I prefer the former because nobody is going to turn the thing
on, especially not distributions, and that's %99.9999 of users.
