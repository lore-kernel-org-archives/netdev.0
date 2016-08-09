From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 20:42:34 +0900
Message-ID: <CAKD1Yr3d5OF4FOaU3RKFP+CJL-jNrh2YSS=08K+Zp2YThGp1Zg@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net> <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net> <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <d8cd5324-3beb-1afd-37fe-7e4c1e6c4de2@miraclelinux.com> <147361af-2984-02e8-aff3-6b53b5e98b39@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37424 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbcHILm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 07:42:56 -0400
Received: by mail-it0-f43.google.com with SMTP id f6so11393933ith.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 04:42:56 -0700 (PDT)
In-Reply-To: <147361af-2984-02e8-aff3-6b53b5e98b39@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 6:36 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> The use of sin6_scope_id and SO_BINDTODEVICE with different interfaces
>> is incorrect and should be rejected.
>
> I agree, I would actually change the behavior at this point, as it also
> could have security consequences from a network pov.

I can send out a patch to do that. Is it something that can be done in
net, or does it need to go into net-next?
