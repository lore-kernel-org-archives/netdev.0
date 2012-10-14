From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Subject: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 17:38:21 +0200
Message-ID: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58094 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2JNPiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 11:38:21 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so6742671iea.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 08:38:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I detected a small regression since linux 3.6.0:
When I run "ntpq -p" to query the status of my ntp-daemon I receive a
timeout (localhost.localdomain: timed out, nothing received
***Request timed out). Strace shows that connecting to the ipv6
loopback interface times out. If I explicitly use ipv4 (ntpq -4 -p)
everything works as intended. Downgrading to linux 3.5.6 solves that
issue.
I reported a bug both to my distribution
(https://bugs.archlinux.org/task/31775) and to the kernel bugtracker
(https://bugzilla.kernel.org/show_bug.cgi?id=48741) not knowing
exactly which component caused the regression, so I was told to ask
this here. At the kernel-report you find an strace and tcpdump output.
If you need any further information just tell me, but be patient as me
kernel knowledge tends to zero.
Thanks in advance, Jan Hinnerk
