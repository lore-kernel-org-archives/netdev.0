From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 13:37:54 -0500 (EST)
Message-ID: <20151124.133754.654421175431044735.davem@davemloft.net>
References: <20151123171103.00007699@unknown>
	<CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
	<1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, jesse.brandeburg@intel.com,
	anjali.singhai@intel.com, jesse@kernel.org, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbbKXSh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:37:58 -0500
In-Reply-To: <1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 24 Nov 2015 18:43:35 +0100

> On Tue, Nov 24, 2015, at 18:32, Tom Herbert wrote:
>> As you said this in only feedback and nobody is forcing anyone to do
>> anything. But encouraging HW vendors to provide generic mechanisms so
>> that your users can use whatever protocol they want is the exact
>> _opposite_ of punishing users, this is very much a pro-user direction.
> 
> Some users will suffer worse performance in case we don't correctly set
> ip_summed for a specific protocol before we do the copy operations from
> user space into skbs but if they are always done in the driver.

Your concern presumes that looking backwards is as important as looking
forward.

We want to simplify things _and_ move away from protocol specific
csums, and if some old crufty hardware based systems pay some performance
cost for this I say so be it.

So this is not a valid argument against Tom's changes in my mind.
