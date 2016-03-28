From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 09:54:19 -0700
Message-ID: <CALx6S35beVmxdp8D_xp+5GthHuFekR7TDemZn64LzPA5thYPvw@mail.gmail.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	<1458944964-12890-3-git-send-email-edumazet@google.com>
	<56F95884.8010901@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36683 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbcC1QyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 12:54:20 -0400
Received: by mail-io0-f177.google.com with SMTP id q128so11735428iof.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 09:54:20 -0700 (PDT)
In-Reply-To: <56F95884.8010901@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 9:15 AM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 03/25/2016 03:29 PM, Eric Dumazet wrote:
>>
>> UDP sockets are not short lived in the high usage case, so the added
>> cost of call_rcu() should not be a concern.
>
>
> Even a busy DNS resolver?
>
Should use connectionless UDP sockets.

> rick jones
