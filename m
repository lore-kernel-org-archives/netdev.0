From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] inetpeer: ensure to set the maximum tokens the first
 time
Date: Thu, 27 Sep 2012 15:39:13 +0200
Message-ID: <50645701.5080900@6wind.com>
References: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>  <1348750405.5093.1234.camel@edumazet-glaptop>  <506452F3.4090409@6wind.com>  <1348752600.5093.1275.camel@edumazet-glaptop> <1348752886.5093.1282.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48507 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab2I0NjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 09:39:16 -0400
Received: by eekb15 with SMTP id b15so932711eek.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 06:39:15 -0700 (PDT)
In-Reply-To: <1348752886.5093.1282.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/09/2012 15:34, Eric Dumazet a =C3=A9crit :
> On Thu, 2012-09-27 at 15:30 +0200, Eric Dumazet wrote:
>
>> So find the right initializer ?
>>
>> p->rate_last =3D jiffies;
>> p->rate_tokens =3D TOKENS_INIT;
>>
>>
>
> Or :
>
> p->rate_last =3D jiffies - 60*HZ;
>
> since the rates_tokens initial value is protocol/family dependent
Yes, this will avoid to pass the timeout arg to inet_getpeer()
