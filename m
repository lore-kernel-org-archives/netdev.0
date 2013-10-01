From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 4/4] ip_tunnel: Remove double unregister of the fallback
 device
Date: Tue, 01 Oct 2013 13:30:51 +0200
Message-ID: <524AB26B.1070700@6wind.com>
References: <20131001093359.GG7660@secunet.com> <20131001093737.GJ7660@secunet.com> <524A9D4C.9030900@6wind.com> <20131001104046.GK7660@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:58038 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173Ab3JALa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 07:30:58 -0400
Received: by mail-wg0-f54.google.com with SMTP id m15so6969802wgh.21
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 04:30:57 -0700 (PDT)
In-Reply-To: <20131001104046.GK7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/2013 12:40, Steffen Klassert a =E9crit :
> On Tue, Oct 01, 2013 at 12:00:44PM +0200, Nicolas Dichtel wrote:
>>
>> Note that there is the same problem in
>> net/ipv6/ip6_tunnel.c:ip6_tnl_destroy_tunnels() introduced by
>> 0bd8762824e7
>> ("ip6tnl: add x-netns support").
>>
>> Should I send a patch for it or would you take care of it?
>
> I don't mind either way. But you noticed the problem, so
> feel free to send a patch yourself.
>
Ok, I will dot it.

Thank you
