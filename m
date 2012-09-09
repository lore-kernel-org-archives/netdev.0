From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Sun, 09 Sep 2012 17:39:03 -0400 (EDT)
Message-ID: <20120909.173903.593154957401069229.davem@davemloft.net>
References: <50360C81.6000009@draigBrady.com>
	<1345722015.5904.675.camel@edumazet-glaptop>
	<alpine.LNX.2.01.1209091954120.15847@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, P@draigBrady.com, brutus@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab2IIVjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2012 17:39:06 -0400
In-Reply-To: <alpine.LNX.2.01.1209091954120.15847@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@inai.de>
Date: Sun, 9 Sep 2012 19:54:42 +0200 (CEST)

>=20
> On Thursday 2012-08-23 13:40, Eric Dumazet wrote:
>>On Thu, 2012-08-23 at 11:57 +0100, P=E1draig Brady wrote:
>>
>>> Just to quantify the loopback testing compat issue.
>>> I often do stuff like the following to test latency.
>>> Will that be impacted?
>>>=20
>>>   tc qdisc add dev lo root handle 1:0 netem delay 20msec
>>>=20
>>
>>Yes this will. At least for tcp traffic this wont "work".
>>
>>TCP friends bypass layers, by directly queuing skbs to sockets.
>>
>>-> no iptables,=20
>=20
> If it amounts to that, you will have upset users rather soon.

This is over "loopback", you're just being rediculous.  %99.9999 of
people simply do not care.
