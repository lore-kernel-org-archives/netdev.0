From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 21:57:32 +0200
Message-ID: <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	<1350242941.21172.17023.camel@edumazet-glaptop>
	<CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	<1350244485.21172.17077.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:57380 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab2JNT5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 15:57:32 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so6897859iea.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 12:57:32 -0700 (PDT)
In-Reply-To: <1350244485.21172.17077.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sun, 2012-10-14 at 21:48 +0200, Jan Hinnerk Stosch wrote:
>
>> ntp.conf is (without comments):
>> server fritz.box iburst
>> restrict default noquery nopeer nomodify
>> restrict 127.0.0.1
>> restrict ::1
>> driftfile /var/lib/ntp/ntp.drift
>> logfile /var/log/ntp.log
>>
>> "lsof -p `pidof ntpd`" gives nothing
>>
>> and "ntpq -p ::1" results in the same timeout error "::1: timed out,
>> nothing received
>> ***Request timed out".
>
> So your ntpd is not running ?
>
> ps aux | grep ntpd
>
>
>

No, of course it is running:
ntp        368  0.0  0.0  31288  2128 ?        Ss   16:51   0:00
/usr/bin/ntpd -g -u ntp:ntp
