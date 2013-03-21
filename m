From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 03:05:18 -0700
Message-ID: <CANP3RGfBMXe=6==vtzmBENzeO_JTfMPFT40Yvt0hxGjAKPN9SQ@mail.gmail.com>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	<CANP3RGfWh1PVavxd-5gy1KvocgRiTNcm-bYZ=aMG6N6vPgyWnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:60842 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297Ab3CUKFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:05:19 -0400
Received: by mail-ob0-f172.google.com with SMTP id tb18so2661636obb.3
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 03:05:19 -0700 (PDT)
In-Reply-To: <CANP3RGfWh1PVavxd-5gy1KvocgRiTNcm-bYZ=aMG6N6vPgyWnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've never understood the usefulness of the 'IP ID increments by one'
check in the GRO TCP path anyway.

I think the above logic holds for non-TCP GRO in exactly the same way.
Furthermore, there's nothing like it in IPv6 (due to the outright lack
of an IPv6 ID field).

(And I have to learn to pay attention to those stupid 3 little
gray-on-white dots that hide the entire email I'm replying to)
