From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Mon, 8 Mar 2010 15:11:14 +0100
Message-ID: <f69abfc31003080611xde6fe26v150dd1fa90b82928@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267798077.2576.17.camel@myhost>
	 <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
	 <c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
	 <f69abfc31003080610m2701309ekd1a4a38ac2685703@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:20113 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab0CHOLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 09:11:16 -0500
Received: by ey-out-2122.google.com with SMTP id 25so275793eya.5
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 06:11:14 -0800 (PST)
In-Reply-To: <f69abfc31003080610m2701309ekd1a4a38ac2685703@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is ping afterwards:

debian:~# ping -c 1 192.168.1.38

PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.


  tx   ram addr = c371c202 , data len = 62

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

  0xc371c20e : 45 00

  0xc371c212 : 00 54 00 00 40 00 40 01 b6 f0 c0 a8 01 42 c0 a8

  0xc371c222 : 01 26 08 00 65 51 1a 07 00 01 92 00 95 4b 5f 57

  0xc371c232 : 07 00 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15

  0xc371c242 : 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25

  0xc371c252 : 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35

  0xc371c262 : 36 37



  tx   ram addr = c371c202 , data len = 2a

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0806

  0xc371c20e : 00 01

  0xc371c212 : 08 00 06 04 00 01 00 04 d9 80 94 cd c0 a8 01 42

  0xc371c222 : 00 00 00 00 00 00 c0 a8 01 26



  rx   ram addr = c35d2020 , data len = 3c

  dst:00:04:d9:80:94:cd src:00:18:f3:fe:84:84 type: 0x0806

  0xc35d202c : 00 01

  0xc35d2030 : 08 00 06 04 00 02 00 18 f3 fe 84 84 c0 a8 01 26

  0xc35d2040 : 00 04 d9 80 94 cd c0 a8 01 42 00 00 00 00 00 00

  0xc35d2050 : 00 00 00 00 00 00 00 00 00 00 00 00





--- 192.168.1.38 ping statistics ---

1 packets transmitted, 0 received, 100% packet loss, time 0ms

Yegor
