From: Kevin Wilson <wkevils@gmail.com>
Subject: ping_group_range documentation patch (question)
Date: Fri, 7 Jun 2013 15:56:13 +0300
Message-ID: <CAGXs5wUg-WjRM2Ky2wckQdv0M7mm51KNXSFZvWUf03Jr0Q-ueQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: amwang@redhat.com, lorenzo@google.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:54381 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab3FGM4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 08:56:15 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so1205353oag.20
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 05:56:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
There was this patch which was sent in the past (4.11.13)
and was not integrated:
http://www.linuxhorizon.com/9-linux/9871b9d326872317.htm

Now, there is no entry about /proc/sys/net/ipv4/ping_group_range in
the Documentation/networking/ip-sysctl.txt file.

When I try
echo 1000 1000 > /proc/sys/net/ipv4/ping_group_range
It does not say an error,
and then su to a user with uid and gid of 1000,
I can ping successfully using ICMP socket.

Now, when I try, according to "set enable it for the world" as mentioned
in that documentation patch, and run:
echo 0  4294967295 >   /proc/sys/net/ipv4/ping_group_range
I get
-bash: echo: write error: Invalid argument


Any ideas  what should I do in order  to enable ICMP sockets "for all the world"
so any use can use them ? and shouldn't this be documented in
Documentation/networking/ip-sysctl.tx?

regards,
Kevin
