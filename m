From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 21:54:45 +0200
Message-ID: <1350244485.21172.17077.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41247 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182Ab2JNTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 15:54:50 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so1303402wib.1
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 12:54:49 -0700 (PDT)
In-Reply-To: <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 21:48 +0200, Jan Hinnerk Stosch wrote:

> ntp.conf is (without comments):
> server fritz.box iburst
> restrict default noquery nopeer nomodify
> restrict 127.0.0.1
> restrict ::1
> driftfile /var/lib/ntp/ntp.drift
> logfile /var/log/ntp.log
> 
> "lsof -p `pidof ntpd`" gives nothing
> 
> and "ntpq -p ::1" results in the same timeout error "::1: timed out,
> nothing received
> ***Request timed out".

So your ntpd is not running ?

ps aux | grep ntpd
