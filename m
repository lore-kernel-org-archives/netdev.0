From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Thu, 01 Dec 2011 04:50:07 +0100
Message-ID: <1322711407.2577.4.camel@edumazet-laptop>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	 <20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	 <CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43121 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab1LADuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:50:11 -0500
Received: by eaak14 with SMTP id k14so1587448eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:50:10 -0800 (PST)
In-Reply-To: <CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 18:11 -0800, Maciej =C5=BBenczykows=
ki a
=C3=A9crit :

> TOS values are relevant within a LAN/WAN/Organization/AS, but are not
> relevant internet-wide.
> Almost all AS-boundary gateways/routers will do TOS remarking to thei=
r
> own internal specifications.

Thats a shame, especially if ECN is screwed up.
