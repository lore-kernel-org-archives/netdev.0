From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 00/15] introduce programable flow dissector
 and cls_flower
Date: Thu, 14 May 2015 11:44:37 +0200
Message-ID: <20150514094437.GC2197@nanopsycho.mtl.com>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
 <20150513.152102.606157874586561609.davem@davemloft.net>
 <CALx6S36XpD7VjygyfG1mRpX3xgHyXjDQQYU8tBRCjuRgckQasQ@mail.gmail.com>
 <20150513.160148.993178492595324237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com, kaber@trash.net,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35639 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbbENJoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 05:44:44 -0400
Received: by wgnd10 with SMTP id d10so66914857wgn.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 02:44:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150513.160148.993178492595324237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 13, 2015 at 10:01:48PM CEST, davem@davemloft.net wrote:
>From: Tom Herbert <tom@herbertland.com>
>Date: Wed, 13 May 2015 15:27:59 -0400
>
>>> I'm sure there will be some performance improvements possible, and I
>>> hope you will look into making sure this new programmable classifier
>>> is as light weight as possible.
> ...
>
>> I still have concerns about making flow_dissector more complex like
>> this. This still seems like it should this programmable logic be done
>> in a separate function. We call flow_dissector at least once per
>> packet via skb_get_hash, it is in the critical path, and adding
>> several conditionals can only slow it down and provides no new value
>> to skb_get_hash. At the very least can we at least get some
>> performance numbers to show impact of this?
>
>The part of what I said to Jiri above is meant exactly to ensure that
>he handles this.
>
>If we need a specialized fast path for the skb_get_hash() code paths,
>so be it.
>
>But I'm not going to denouce his entire efforts for something that
>hasn't even been shown to be an issue yet.  And if it is, I'm sure
>Jiri will work to address it.

Yes, sure thing.
