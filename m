From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen: tricks
Date: Thu, 24 Sep 2009 12:32:57 +0200
Message-ID: <4ABB4AD9.50002@gmail.com>
References: <20090922224902.17ed6cc4@nehalam> <20090923174141.1d350103@s6510> <200909241310.05297.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37105 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbZIXKc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 06:32:56 -0400
In-Reply-To: <200909241310.05297.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko a =E9crit :
> On Thursday 24 September 2009 03:41:41 Stephen Hemminger wrote:
>> Other kernel config help:
>>   - turn off lock dependency checker, kmecheck, page alloc debug
>>     basically anything that slows stuff down
>>   - turn off content group scheduler
> Maybe, but i'm not sure (i can't test it):
> Disable randomize VA space? On embedded boards it was helping.=20
> In some case disabling SMP helped, when various SMP locks involved, b=
ut maybe=20
> not for pktgen.
>=20
>

pktgen is a kernel module, and is not affected by randomize VA space.

But of course, disabling SMP must help, as long as your machine needs
one cpu only :)

