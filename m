From: Minoru Usui <mi.usui@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 22:34:13 +0900
Message-ID: <b10243b50906010634r1df4ed71y904eb629c89a6f70@mail.gmail.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
	 <1243776293.3966.241.camel@dogo.mojatatu.com>
	 <20090531195557.GA2777@ami.dom.local>
	 <1243813216.3966.254.camel@dogo.mojatatu.com>
	 <20090601060638.GA4256@ff.dom.local>
	 <1243861410.3966.268.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:50104 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbZFANeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 09:34:12 -0400
Received: by qyk36 with SMTP id 36so1602431qyk.33
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 06:34:14 -0700 (PDT)
In-Reply-To: <1243861410.3966.268.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/1 jamal <hadi@cyberus.ca>:
> On Mon, 2009-06-01 at 06:06 +0000, Jarek Poplawski wrote:
>
>>
>> But how about that (of course extremely rude) case "tc filter replace"
>> is run with a new prio?
>
>
> Jarek, sir, handyman extraordinaire, handsome devil, and lover of
> kittens I humbly opine that we need to handle that case.
> How about going back to your original idea of defining tp_created? With
> apologies to Minoru (he must be thinking we are lunatics by now), how
> does the attached changed patch look to you?

It looks good to me, because it's simple and really understandable.
I think below issue should separate from above patch, because it's
easy to come to understand a patch.

How about that?
If it's ok, I'll test it tomorrow.

> Before you throw another rock, there is another issue which will be
> caused by this rude misconfig:
> "replace" really means "get rid of the old and add this new one".
> But for the last 50 years we do not "get rid of the old". I cant think
> of a clean way to do it sans shaving one of the kittens. One simple
> thing to do is to printk a warning when detecting this error. I think
> one needs to draw a line where bad config affects your life - in this
> case i dont think it is worth big changes..
>
> cheers,
> jamal
>
