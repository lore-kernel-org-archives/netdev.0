From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 19:42:51 +0100
Message-ID: <1448390571.603479.449028625.4A535D78@webmail.messagingengine.com>
References: <20151123171103.00007699@unknown>
 <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
 <1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
 <20151124.133754.654421175431044735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, jesse.brandeburg@intel.com,
	anjali.singhai@intel.com, jesse@kernel.org, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41568 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292AbbKXSmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:42:52 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id ED02A2082E
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 13:42:51 -0500 (EST)
In-Reply-To: <20151124.133754.654421175431044735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015, at 19:37, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 24 Nov 2015 18:43:35 +0100
> 
> > On Tue, Nov 24, 2015, at 18:32, Tom Herbert wrote:
> >> As you said this in only feedback and nobody is forcing anyone to do
> >> anything. But encouraging HW vendors to provide generic mechanisms so
> >> that your users can use whatever protocol they want is the exact
> >> _opposite_ of punishing users, this is very much a pro-user direction.
> > 
> > Some users will suffer worse performance in case we don't correctly set
> > ip_summed for a specific protocol before we do the copy operations from
> > user space into skbs but if they are always done in the driver.
> 
> Your concern presumes that looking backwards is as important as looking
> forward.
> 
> We want to simplify things _and_ move away from protocol specific
> csums, and if some old crufty hardware based systems pay some performance
> cost for this I say so be it.
> 
> So this is not a valid argument against Tom's changes in my mind.

I agree with you and we should move forward with this. It is just
something to keep in mind IMHO. Otherwise maintenance of those
additional bits did not hurt a lot IMHO.

Bye,
Hannes
