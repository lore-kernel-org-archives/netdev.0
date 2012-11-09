From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/3] ipip: advertise tunnel param via rtnl
Date: Fri, 09 Nov 2012 18:00:59 +0100
Message-ID: <509D36CB.9030509@6wind.com>
References: <1352467239.19779.564.camel@edumazet-glaptop>  <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>  <1352477401-19044-2-git-send-email-nicolas.dichtel@6wind.com> <1352479020.19779.741.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:64508 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748Ab2KIRBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 12:01:03 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so1549747eaa.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 09:01:01 -0800 (PST)
In-Reply-To: <1352479020.19779.741.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/11/2012 17:37, Eric Dumazet a =C3=A9crit :
> On Fri, 2012-11-09 at 17:09 +0100, Nicolas Dichtel wrote:
>> It is usefull for daemons that monitor link event to have the full p=
arameters of
>> these interfaces when a rtnl message is sent.
>> It allows also to dump them via rtnetlink.
>>
>> It is based on what is done for GRE tunnels.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>
> Nice !
>
> Note this also adds support for link creation.
>
> Do you plan to add iproute2 support for :
>
> ip link add ipip1 type ipip remote 10.246.8.36
>
> Thanks
>
> Acked-by: Eric Dumazet <edumazet@google.com>

If the principle is approved, yes. If we add it, we will have two
ways to manage these tunnels, via netlink and via ioctl, is it ok?

A side effect could be to have an option or an argument to the module t=
o not=20
create the control interface (tunl0, sit0, ...).
