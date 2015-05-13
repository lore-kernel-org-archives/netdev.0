From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 00/15] introduce programable flow dissector
 and cls_flower
Date: Wed, 13 May 2015 16:01:48 -0400 (EDT)
Message-ID: <20150513.160148.993178492595324237.davem@davemloft.net>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
	<20150513.152102.606157874586561609.davem@davemloft.net>
	<CALx6S36XpD7VjygyfG1mRpX3xgHyXjDQQYU8tBRCjuRgckQasQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com, kaber@trash.net,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965321AbbEMUBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:01:53 -0400
In-Reply-To: <CALx6S36XpD7VjygyfG1mRpX3xgHyXjDQQYU8tBRCjuRgckQasQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 13 May 2015 15:27:59 -0400

>> I'm sure there will be some performance improvements possible, and I
>> hope you will look into making sure this new programmable classifier
>> is as light weight as possible.
 ...

> I still have concerns about making flow_dissector more complex like
> this. This still seems like it should this programmable logic be done
> in a separate function. We call flow_dissector at least once per
> packet via skb_get_hash, it is in the critical path, and adding
> several conditionals can only slow it down and provides no new value
> to skb_get_hash. At the very least can we at least get some
> performance numbers to show impact of this?

The part of what I said to Jiri above is meant exactly to ensure that
he handles this.

If we need a specialized fast path for the skb_get_hash() code paths,
so be it.

But I'm not going to denouce his entire efforts for something that
hasn't even been shown to be an issue yet.  And if it is, I'm sure
Jiri will work to address it.
