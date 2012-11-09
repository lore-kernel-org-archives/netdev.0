From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Fri, 09 Nov 2012 10:43:34 +0100
Message-ID: <509CD046.4060302@6wind.com>
References: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com> <20121105.120017.1189906314924845791.davem@davemloft.net> <5097F5DF.7040507@6wind.com> <20121105.124305.1002288640313724910.davem@davemloft.net> <5098127A.2040405@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51740 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2KIJnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 04:43:39 -0500
Received: by mail-bk0-f46.google.com with SMTP id jk13so1531480bkc.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 01:43:38 -0800 (PST)
In-Reply-To: <5098127A.2040405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/11/2012 20:24, Nicolas Dichtel a =E9crit :
> Le 05/11/2012 18:43, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Mon, 05 Nov 2012 18:22:39 +0100
>>
>>> Le 05/11/2012 18:00, David Miller a =E9crit :
>>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>> Date: Mon,  5 Nov 2012 16:28:18 +0100
>>>>
>>>>> The kernel uses some default metric when routes are managed. For
>>>>> example, a
>>>>> static route added with a metric set to 0 is inserted in the kern=
el
>>>>> with
>>>>> metric 1024 (IP6_RT_PRIO_USER).
>>>>> It is useful for routing daemons to know these values, to be able=
 to
>>>>> set routes
>>>>> without interfering with what the kernel does.
>>>>>
>>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>>
>>>> But these belong in the libc headers anyways.
>>>>
>>>> If we haven't provided them for so long, there's no real value of
>>>> adding them now.
>>>>
>>> But how can a daemon know which default values are used? If it want=
s
>>> to add a route with metric =3D default + x, it should first add it =
with
>>> metric =3D 0, check the result and then change the metric.
>>
>> What do we do on the ipv4 side and how do daemons cope in that situa=
tion?
>>
> In IPv4, there is no such default metric. If you add a route with met=
ric X, it
> remains X in the kernel, even if it's 0.
So we need to duplicate these values in the daemon?
