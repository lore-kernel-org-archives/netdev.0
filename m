From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next v2] ipv6: Do not iterate over all interfaces when
 finding source address on specific interface.
Date: Mon, 13 Jul 2015 17:38:48 +0900
Message-ID: <CAAedzxp8RAn3VZVZmWA_vLMspEyt_-nWe3RBKXWfsUoFRz97Hg@mail.gmail.com>
References: <559F7B27.6030205@miraclelinux.com> <20150710.231943.1262522002810525503.davem@davemloft.net>
 <CAAedzxpMP-DmKOy-BfQkReGWmbujGqM_JsdmYtcuxVDqAdXNKg@mail.gmail.com> <55A35B72.2060009@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38838 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbGMIjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:39:10 -0400
Received: by wicmv11 with SMTP id mv11so55285551wic.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 01:39:08 -0700 (PDT)
In-Reply-To: <55A35B72.2060009@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 July 2015 at 15:32, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
> Hi,
>
> Erik Kline wrote:
>> Hmm, when I run a UML linux with this patch (which, I'm ashamed to
>> say, I failed to do before) I get these kinds of errors:
>>
>>     unregister_netdevice: waiting for <TAPdevice> to become free.
>> Usage count = 1
>>     unregister_netdevice: waiting for <TAPdevice> to become free.
>> Usage count = 1
>>
>> Perhaps they're unrelated... I'm still investigating.
>
> Would you test attached patch please?

That does look logically correct, so +1 to it regardless, but it does
not seem to have fixed the issue I'm seeing.

I still haven't produced the smallest possible demo test program.
