From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] neigh: Netlink notification for administrative NUD state
 change
Date: Mon, 16 Dec 2013 09:23:42 +0100
Message-ID: <52AEB88E.2040004@6wind.com>
References: <52ae21ac.oFg7QoGcVg2CCThY%gilligan@aristanetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bob Gilligan <gilligan@aristanetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35443 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab3LPIYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:24:48 -0500
Received: by mail-wi0-f182.google.com with SMTP id en1so1728193wid.9
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 00:24:47 -0800 (PST)
In-Reply-To: <52ae21ac.oFg7QoGcVg2CCThY%gilligan@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/12/2013 22:39, Bob Gilligan a =E9crit :
>
> The neighbour code sends up an RTM_NEWNEIGH netlink notification if
> the NUD state of a neighbour cache entry is changed by a timer (e.g.
> from REACHABLE to STALE), even if the lladdr of the entry has not
> changed.
>
> But an administrative change to the the NUD state of a neighbour cach=
e
> entry that does not change the lladdr (e.g. via "ip -4 neigh change
> ...  nud ...") does not trigger a netlink notification.  This means
> that netlink listeners will not hear about administrative NUD state
> changes such as from a resolved state to PERMANENT.
>
> This patch changes the neighbor code to generate an RTM_NEWNEIGH
> message when the NUD state of an entry is changed administratively.
>
> Signed-off-by: Bob Gilligan <gilligan@aristanetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
