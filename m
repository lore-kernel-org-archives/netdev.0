From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 14:05:57 +0200
Message-ID: <48847BA5.2020600@trash.net>
References: <20080720.104411.81744468.davem@davemloft.net> <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net> <4883E465.4050405@trash.net> <Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35651 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbYGUMGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 08:06:38 -0400
In-Reply-To: <Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Morris wrote:
> On Mon, 21 Jul 2008, Patrick McHardy wrote:
>
>   
>> This is only the NETFILTER_ADVANCED=n default (for SECURITY=y).
>> The netfilter defaults for NETFILTER_ADVANCED=n should be m/y for
>> things that are needed by mainstream distributions for normal
>> usage.
>>
>> I'm not sure how this is going to be used, James?
>>     
>
> I think the idea now is that everything new is N by default, but the 
> intention is to have this enabled in Fedora/RHEL.

Well, this option (NETFILTER_ADVANCED) was introduced specifically
so Linus doesn't have to go through and enable all the netfilter
options manually :)

The idea was that NETFILTER_ADVANCED=n enables everything needed
by mainstream distributions and hides the rest. We can certainly
change the default for this option, but that makes NETFILTER_ADVANCED
pretty much useless.

> Patrick, would you please fix this up?  The only dev box I have access to 
> at the moment doesn't boot with recent git (I think it's the macbook2 
> issue).

Sure. I'd like to hear whether Linus still wants this changed though.


