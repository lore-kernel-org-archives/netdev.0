From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RESEND PATCH net-next] ipv6/multipath: remove flag NLM_F_EXCL
 after the first nexthop
Date: Mon, 05 Nov 2012 09:30:06 +0100
Message-ID: <5097790E.1080701@6wind.com>
References: <50896D47.7030500@6wind.com> <1351846702-4982-1-git-send-email-nicolas.dichtel@6wind.com> <20121102.213857.2276553238313329445.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, joe@perches.com,
	bernat@luffy.cx, eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39428 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2KEIaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 03:30:10 -0500
Received: by mail-wi0-f178.google.com with SMTP id hr7so2846374wib.1
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 00:30:09 -0800 (PST)
In-Reply-To: <20121102.213857.2276553238313329445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/11/2012 02:38, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri,  2 Nov 2012 09:58:22 +0100
>
>> fib6_add_rt2node() will reject the nexthop if this flag is set, so
>> we perform the check only for the first nexthop.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> It seems a bit hackish, but I don't have any better ideas, so
> applied, thanks.
>
Yes, I agree. It's why I didn't include it in the initial patch ... but=
 I also=20
didn't find a better way :/
