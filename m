From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/5 (resend)] veth: Allow to create peer link with given
 ifindex
Date: Wed, 08 Aug 2012 17:38:49 +0400
Message-ID: <50226BE9.20601@parallels.com>
References: <501FD0F2.4040609@parallels.com>   <501FD14F.2040209@parallels.com> <5020F5AB.3090101@parallels.com>  <1344364573.2688.13.camel@bwh-desktop.uk.solarflarecom.com>  <50222AC3.8090801@parallels.com> <1344432330.13142.188.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5359 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964926Ab2HHNjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2012 09:39:08 -0400
In-Reply-To: <1344432330.13142.188.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> You're right, I've missed that fact :( The good news is that we still can
>> use the ifmp->ifi_index for the peer index configuration. We just need to
>> assume that if the caller specified the ifindex for the veth master device,
>> then it's aware of this possibility and should explicitly configure (or set
>> to 0) the peer's ifindex as well. Like this:
>>
>> 	if (ifmp && (dev->ifindex != 0))
>> 		peer->ifindex = ifmp->ifi_index;
>>
>> Does this assumption work from you POV?
> 
> Yes, that looks like a neat way to do it.  Maybe with an explanatory
> comment?

Yes, sure. I will resend the set shortly.
Thanks for the feedback!

> Ben.
> 

Thanks,
Pavel
