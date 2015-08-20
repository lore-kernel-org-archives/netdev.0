From: Tomas Papan <tomas.papan@gmail.com>
Subject: e1000e: possible reggresion?
Date: Thu, 20 Aug 2015 21:37:08 +0200
Message-ID: <665F7BF9-6041-4E7D-8A37-1B87770F9FAA@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35195 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbHTThM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 15:37:12 -0400
Received: by wicne3 with SMTP id ne3so154455158wic.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 12:37:11 -0700 (PDT)
Received: from padme.starwars (109-230-4-45.dynamic.orange.sk. [109.230.4.45])
        by smtp.gmail.com with ESMTPSA id i1sm6834312wjq.42.2015.08.20.12.37.09
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 12:37:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I=E2=80=99m observing a freeze with the recent kernel (4.2-rc7). Unfort=
unately I can=E2=80=99t preserver the full traces.
There is nothing in the messages after reboot, I was just lucky one tim=
e to see it when tail -f /var/log/messages was running.
This is the only line which I was able to get:
	eth1 (e1000e): transmit queue 0 timed out

I=E2=80=99ve got this message in the past, but the ethtool -K eth1 tso =
off solved that. I=E2=80=99m always running
this command at the boot time since then. There is no issue with 4.2-rc=
4. It is hard to bisect,
because this machine is used as headless server and it happens randomly=
 (usually within 2 hours).

Do you have any idea how to trace it or what can I do?
Please keep me on CC since I=E2=80=99m not subscribed on this list

Regards
Tomas
