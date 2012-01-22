From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sun, 22 Jan 2012 13:00:33 -0800
Message-ID: <4F1C78F1.2070409@candelatech.com>
References: <4F1AFA84.5050201@candelatech.com> <20120121.134036.1565691107664746948.davem@davemloft.net> <4F1C3DF5.8070802@candelatech.com> <20120122.141447.1622071157220040891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47173 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2AVVAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 16:00:48 -0500
In-Reply-To: <20120122.141447.1622071157220040891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2012 11:14 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Sun, 22 Jan 2012 08:48:53 -0800
>
>> Just to make sure I understand you: You dislike any possible method
>> of changing the behaviour, not just the ones I listed?
>
> That's correct.
>
> And please don't create dependencies on such a change in behavior in
> distributions, otherwise you obliterate the entire reason why I don't
> want the behavior changed.

No worries, I don't have a real distribution and I can't imagine any
real distribution picking up my changes against your wishes.  Just to
be safe, I'll default any changes to the current behaviour.

> There is no reason to change this, it's been like this for more than
> 10 years and no alien planet has exploded as a result even after all
> of this time.

Well, it breaks my (proprietary, and already optimized for my own kernel
hacks) user-space program, and though I could add hacks to
fix it eventually, I think it will be much easier to hack the kernel.

> Just leave it be, I beg you.

I think you may be over-estimating my influence :)

I have much more horrible patches I've been carrying for years and years
and as you say, the alien planets are all doing ok.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
