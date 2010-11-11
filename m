From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Thu, 11 Nov 2010 14:24:27 -0800
Message-ID: <AANLkTikqxjypp-hvxx7m+k7jaky-bU5CGxqchEtJ7kVq@mail.gmail.com>
References: <1289468520.17691.1018.camel@edumazet-laptop>
	<AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
	<1289497978.17691.1582.camel@edumazet-laptop>
	<AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
	<1289504565.17691.1710.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49840 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab0KKWY3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 17:24:29 -0500
Received: by wyb28 with SMTP id 28so1213333wyb.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 14:24:28 -0800 (PST)
In-Reply-To: <1289504565.17691.1710.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 11:42 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 11 novembre 2010 =E0 10:56 -0800, Jesse Gross a =E9crit :
>> On Thu, Nov 11, 2010 at 9:52 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>
>> Before Tom's patch, a warning will be generated if a single queue vl=
an
>> device is stacked on top of a multiqueue physical device that
>> implements ndo_select_queue(). =A0After Tom's patch, we avoid the
>> warning so vlan_dev_select_queue() is merely dead code. =A0Either wa=
y,
>> what's the benefit in keeping it?
>>
>> >
>> >
>> > This logicaly is a second cleanup patch I believe.
>>
>> I'm not arguing against your patch, I just think it should go a step=
 further.
>
> Sure ! Here is the thing ;)
>
> Thanks
>
> [PATCH] vlan: remove ndo_select_queue() logic
>
> Now vlan are lockless, we dont need special ndo_select_queue() logic.
> dev_pick_tx() will do the multiqueue stuff on the real device transmi=
t.
>
> Suggested-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yes, that's what I was thinking of.  Thanks Eric.
