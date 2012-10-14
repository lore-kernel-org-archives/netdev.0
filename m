From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 21:29:01 +0200
Message-ID: <1350242941.21172.17023.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41384 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab2JNT3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 15:29:07 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3888212wgb.1
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 12:29:06 -0700 (PDT)
In-Reply-To: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 17:38 +0200, Jan Hinnerk Stosch wrote:
> Hi,
> I detected a small regression since linux 3.6.0:
> When I run "ntpq -p" to query the status of my ntp-daemon I receive a
> timeout (localhost.localdomain: timed out, nothing received
> ***Request timed out). Strace shows that connecting to the ipv6
> loopback interface times out. If I explicitly use ipv4 (ntpq -4 -p)
> everything works as intended. Downgrading to linux 3.5.6 solves that
> issue.
> I reported a bug both to my distribution
> (https://bugs.archlinux.org/task/31775) and to the kernel bugtracker
> (https://bugzilla.kernel.org/show_bug.cgi?id=48741) not knowing
> exactly which component caused the regression, so I was told to ask
> this here. At the kernel-report you find an strace and tcpdump output.
> If you need any further information just tell me, but be patient as me
> kernel knowledge tends to zero.
> Thanks in advance, Jan Hinnerk
> --


What gives :

cat /etc/ntp.conf
lsof -p `pidof ntpd`
ntpq -p ::1
