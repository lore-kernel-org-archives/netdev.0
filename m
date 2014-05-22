From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: modify tunnel's name when changing link's name
Date: Wed, 21 May 2014 21:12:30 -0700
Message-ID: <CAHA+R7PnmDj-6W-fo5g7poNuAb4tGgzgo5dFLGjiR2DuKjX0Jw@mail.gmail.com>
References: <537AE7D1.4090702@cn.fujitsu.com>
	<CAHA+R7O-yr5w6T2PUMXyofyZxmyyaGPSBUN67WTMVdvogmSmmA@mail.gmail.com>
	<CAHA+R7Oc6qwd82riF8T+wXyopfMP9RquKUXty6WUpGs-n5ac5Q@mail.gmail.com>
	<1400631582.5367.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	stephen hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:38487 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaEVEMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 00:12:31 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so4696021qgf.17
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 21:12:30 -0700 (PDT)
In-Reply-To: <1400631582.5367.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 5:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-05-20 at 16:20 -0700, Cong Wang wrote:
>> On Tue, May 20, 2014 at 12:21 PM, Cong Wang <cwang@twopensource.com> wrote:
>> >
>> > I am working on a patch.
>>
>> For now, I think we just fix the renaming issue.
>> Please try this patch below (I already tested it actually).
>>
>> IPv6 part is on the way.
>
> This looks like bloat.
>
> Why do we need to copy dev->name into tunnel->param.name ?
>
> struct ip_tunnel_parm is legacy, but we do not need to store
> anything in tunnel->param.name
>
> This can be filled when/if sent to userland.
>
>

Yeah, that should work as well, it's a even quicker fix.

I think we will need a notifier for tunnels anyway, for example, when
the lower device (iflink) gets unregistered.
