From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI: Polling function requesting extra calls - difference
 between 3.18.11 and 4.0.0
Date: Thu, 23 Apr 2015 11:28:52 -0700
Message-ID: <1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35862 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030612AbbDWS2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:28:55 -0400
Received: by iebrs15 with SMTP id rs15so67396258ieb.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:28:54 -0700 (PDT)
In-Reply-To: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 20:18 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:

>=20
> Can you help us with this, please? Does bgmac use NAPI incorrectly?
> Were there some important changes in 3.19 or 4.0?
>=20

Right they were important changes in NAPI indeed :

3b47d30396ba net: gro: add a per device gro flush timer
d75b1ade567f net: less interrupt masking in NAPI
bc9ad166e38a net: introduce napi_schedule_irqoff()

This requested some fixes in various drivers :

commit f31ec95fa19e07a8beebcc0297284f23aa57967e
commit 24e579c8898aa641ede3149234906982290934e5
commit 6088beef3f7517717bd21d90b379714dd0837079
commit f104fedc0da126abe93dd0f4a9fa13e5133bf9df
commit 7a05dc64e2e4c611d89007b125b20c0d2a4d31a5
commit 001ce546bb537bb5b7821f05633556a0c9787e32
commit 3079c652141f9d6377417a7e8fd650c9948df65e
commit 8acdf999accfd95093db17f33a58429a38782060
commit 6a6dc08ff6395f58be3ee568cb970ea956f16819
