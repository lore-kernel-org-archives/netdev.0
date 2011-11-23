From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 0/10] bql: Byte Queue Limits
Date: Wed, 23 Nov 2011 07:00:37 +0100
Message-ID: <1322028037.1298.6.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1111222134590.9126@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43739 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1KWGAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:00:41 -0500
Received: by fagn18 with SMTP id n18so1283828fag.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 22:00:40 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111222134590.9126@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 21:52 -0800, Tom Herbert a =C3=A9crit =
:
> Changes from last version:
>   - Rebase to 3.2
>   - Added CONFIG_BQL and CONFIG_DQL
>   - Added some cache alignment in struct dql, to split read only, wri=
teable
>     elements, and split those elements written on transmit from those
>     written at transmit completion (suggested by Eric).
>   - Split out adding xps_queue_release as its own patch.
>   - Some minor performance changes, use likely and unlikely for some
>     conditionals.
>   - Cleaned up some "show" functions for bql (pointed out by Ben).
>   - Change netdev_tx_completed_queue to do check xoff, check
>     availability, and then check xoff again.  This to prevent potenti=
al
>     race conditions with netdev_sent_queue (as Ben pointed out).
>   - Did some more testing trying to evaluate overhead of BQL in the
>     transmit path.  I see about 1-3% degradation in CPU utilization
>     and maximum pps when BQL is enabled.  Any ideas to beat this
>     down as much as possible would be appreciated!
>   - Added high versus low priority traffic test to results below.
>  =20

Excellent, I plan to review and test this today

Thanks !
