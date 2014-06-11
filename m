From: Kostya Serebryany <kcc@google.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 17:38:57 +0400
Message-ID: <CAN=P9phzd34JtS_+Y1uimfmdZhyYNfTRPVXmmz7GG-+UJOebWQ@mail.gmail.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	<1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.02.1406101726390.11647@dtop>
	<1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.10.1406102114520.28698@dinf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35467 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711AbaFKNi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:38:58 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so6259778igd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 06:38:58 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.10.1406102114520.28698@dinf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ran our udpkill util against 3.10.42 with both of your patches applied...

[plain text]
Could you please tell us more about udpkill?
Will it makes sense to run address-sanitized-kernel with udpkill?

--kcc
