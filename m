From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Tue, 06 Sep 2011 08:52:15 +0200
Message-ID: <4E65C31F.1010809@gmail.com>
References: <20110902172220.830228928@vyatta.com>	<20110902172247.396753508@vyatta.com>	<4E614CF7.7030700@gmail.com>	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>	<4E6272BC.4020707@gmail.com>	<20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>	<4E632A2E.5040805@gmail.com>	<20110904093634.685d7c56@nehalam.ftrdhcpuser.net>	<4E65046E.1020005@gmail.com> <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48202 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab1IFGwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 02:52:13 -0400
Received: by wwf5 with SMTP id 5so5859532wwf.1
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2011 23:52:12 -0700 (PDT)
In-Reply-To: <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/09/2011 19:57, Stephen Hemminger a =E9crit :
> The root cause of the problem is applications that don't deal with un=
resolved
> IPv6 addresses. I already had to solve this in our distribution for N=
TP in a
> not bridge related problem. It is better to fix the applications to u=
nderstand
> IPv6 address semantics than to try and force bridge to behave in a wa=
y that
> is friendly to these applications.

Thanks for clarifying.

> The earlier mail said it is a problem with dnsmasq and radvd. Let's w=
ork on understanding
> if they need to be updated before jumping in with hacks to the bridge=
 code.
>

I really support the idea to keep the current behavior (assert carrier =
on br0 when at least one port=20
have carrier) and to fix the applications to wait for the IPv6 address =
to be checked (DAD) instead=20
of dying on bind() failure.

Thanks.

	Nicolas.
