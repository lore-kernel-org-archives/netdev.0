From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Mon, 24 Mar 2014 19:07:35 -0400
Message-ID: <5330BAB7.3040501@mojatatu.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us> <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:57853 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaCXXHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:07:39 -0400
Received: by mail-qg0-f48.google.com with SMTP id j107so18743979qga.7
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:07:39 -0700 (PDT)
In-Reply-To: <20140322094852.GB2844@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/14 05:48, Jiri Pirko wrote:
> Fri, Mar 21, 2014 at 01:04:20PM CET, jhs@mojatatu.com wrote:

> Hmm. This got me thinking about netdev and switches well and perhaps the
> switchdev api could be mostly implemented by couple of more ndos and
> feature flags. That way we could stick to your immortal netdev :)
>
>

Perhaps ;->

>>
>> In my view: that (immortal) device for L2/bridging is the bridge or
>> maybe a more barebone version of the bridge (since it has gained a
>> little more weight in recent times).
>
> Well, I do not think that bridge is ideal abstraction for modern switch
> chips. Bridge is very limited.
>

True - but i was more thinking of being inclusive of the smaller
devices. They are mostly L2 only and in very limited scope. And thats
probably 95% of the population. The things you are talking about
are very high end and they can do more. Florian's taxanomy was useful.

> But I don't necessary think it is needed to "mask" as a bride or mimic a
> bridge in any way. DSA does not do that either.
>

I am open to the idea of exposing ports instead of a bridge.
Such ports could be aggregate together to form a bridge when the
hardware is capable.

> switchdev tries to provide an API. Who takes it and use it is up to us.
> OVS, bridge or whatever.
>

As long as you maintain the current user tools I am happy.
Can i run all my iproute2 tools?


>
> Sure, send us a link please.
>

I will post it somewhere. The starting point was L2; if we decide to
go a different direction it may require a different approach.


cheers,
jamal
