From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Sun, 9 Sep 2012 19:54:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209091954120.15847@frira.zrqbmnf.qr>
References: <1344559958-29162-1-git-send-email-brutus@google.com>  <50360C81.6000009@draigBrady.com> <1345722015.5904.675.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigBrady.com>,
	"Bruce \"Brutus\" Curtis" <brutus@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:47934 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab2IIRyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2012 13:54:46 -0400
In-Reply-To: <1345722015.5904.675.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2012-08-23 13:40, Eric Dumazet wrote:
>On Thu, 2012-08-23 at 11:57 +0100, P=C3=A1draig Brady wrote:
>
>> Just to quantify the loopback testing compat issue.
>> I often do stuff like the following to test latency.
>> Will that be impacted?
>>=20
>>   tc qdisc add dev lo root handle 1:0 netem delay 20msec
>>=20
>
>Yes this will. At least for tcp traffic this wont "work".
>
>TCP friends bypass layers, by directly queuing skbs to sockets.
>
>-> no iptables,=20

If it amounts to that, you will have upset users rather soon.
