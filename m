From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Thu, 1 Dec 2011 01:07:54 -0800
Message-ID: <CAHo-Ooyz3pWfqABaPMthfxa-Hz9U3tW_qBrxP3YPx3wKWgqAqQ@mail.gmail.com>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	<CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
	<1322711407.2577.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:33086 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab1LAJHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:07:55 -0500
Received: by ggnr5 with SMTP id r5so1578562ggn.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:07:54 -0800 (PST)
In-Reply-To: <1322711407.2577.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thats a shame, especially if ECN is screwed up.

The ECN bits will in general not be touched (or will even be correctly
updated as required for ECN to function).

However, standard ECN isn't actually particularly usable really anyway
(see Microsoft's DC TCP paper [I believe] for a better alternative).

(There are of course still places in the internet - ran into one at a
motel just recently - where ECN is just plain outright blackholed)
