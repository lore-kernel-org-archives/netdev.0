From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Sun, 16 Jan 2011 11:50:24 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101161144350.8081@obet.zrqbmnf.qr>
References: <54347.1295168081@internode.on.net> <1295169670.3977.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: arthur.marsh@internode.on.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:37858 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab1APKuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jan 2011 05:50:25 -0500
In-Reply-To: <1295169670.3977.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le dimanche 16 janvier 2011 =C3=A0 19:24 +1030, Arthur Marsh a =C3=A9cr=
it :
>
>>With kernels up to and including 2.6.37-git7, inbound telnetd-ssl
>>connections worked fine. With kernel 2.6.37-git9 and later inbound
>>telnetd-ssl connections failed, and on machine shut-down, there
>>were warning messages about daemons not return status.

Which daemons are these? For reference, what distro do you happen
to use?

>> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf=20
>>     netlink: test for all flags of the NLM_F_DUMP composite=20

Each of the hunks in this commit is independent of another.
Would you mind bisecting these too?
