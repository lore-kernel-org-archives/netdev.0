From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Mon, 05 Nov 2012 18:22:39 +0100
Message-ID: <5097F5DF.7040507@6wind.com>
References: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com> <20121105.120017.1189906314924845791.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34538 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab2KERWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 12:22:44 -0500
Received: by mail-bk0-f46.google.com with SMTP id jk13so2115698bkc.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 09:22:43 -0800 (PST)
In-Reply-To: <20121105.120017.1189906314924845791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/11/2012 18:00, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Mon,  5 Nov 2012 16:28:18 +0100
>
>> The kernel uses some default metric when routes are managed. For exa=
mple, a
>> static route added with a metric set to 0 is inserted in the kernel =
with
>> metric 1024 (IP6_RT_PRIO_USER).
>> It is useful for routing daemons to know these values, to be able to=
 set routes
>> without interfering with what the kernel does.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> But these belong in the libc headers anyways.
>
> If we haven't provided them for so long, there's no real value of
> adding them now.
>
But how can a daemon know which default values are used? If it wants to=
 add a=20
route with metric =3D default + x, it should first add it with metric =3D=
 0, check=20
the result and then change the metric.
