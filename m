From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed, 03 Mar 2010 11:07:23 +0100
Message-ID: <1267610843.2997.7.camel@edumazet-laptop>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:40715 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab0CCKH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 05:07:29 -0500
Received: by bwz4 with SMTP id 4so901582bwz.28
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 02:07:27 -0800 (PST)
In-Reply-To: <1267607162.2370.169.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 17:06 +0800, Zhu Yi a =C3=A9crit :

> I simply follow how the code is originally written. As you can see,
> tcp_v4_do_rcv() doesn't always do so. And in the backlog queuing plac=
e,
> we don't even bother to check.

You add a new point where a packet can be dropped, this should be
accounted for, so that admins can have a clue whats going on.

Previously, packet was always queued, and dropped later (and accounted)

Not everybody runs drop monitor :)


