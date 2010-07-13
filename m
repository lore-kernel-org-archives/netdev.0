From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Tue, 13 Jul 2010 18:06:52 -0300
Message-ID: <AANLkTilAHH_qUL481bG7R5lU9jDGK9_364SR-73oHoMb@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	<AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
	<1279032023.2634.384.camel@edumazet-laptop>
	<AANLkTilrIByt4xAHhsBsKo3nDfv0_c3sF-dCiTiYiPnu@mail.gmail.com>
	<1279036193.2634.468.camel@edumazet-laptop>
	<AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2010/7/13 Felipe W Damasio <felipewd@gmail.com>:
> This is the dmesg message:

This error happened at 17:19:59.

A few seconds earlier, I have these on squid's logs:

2010/07/13 17:19:50| clientTryParseRequest: FD 1690
(189.113.65.55:52681) Invalid Request
2010/07/13 17:19:50| clientTryParseRequest: FD 5056
(189.113.74.101:2420) Invalid Request
2010/07/13 17:19:52| clientTryParseRequest: FD 26923
(189.113.74.101:2419) Invalid Request
2010/07/13 17:19:57| parseHttpRequest: Unsupported method 'PASS'
2010/07/13 17:19:57| clientTryParseRequest: FD 17786
(189.113.69.194:2422) Invalid Request
2010/07/13 17:19:57| parseHttpRequest: Unsupported method '<D2>Yk'
2010/07/13 17:19:57| clientTryParseRequest: FD 22554
(189.113.79.151:4225) Invalid Request
2010/07/13 17:19:59| httpReadReply: Excess data from "GET
http://webcs.msg.yahoo.com/crossdomain.xml"

 Maybe with these two errors we can create some kind of trigger
program to help us duplicate this on the lab setup?

 Cheers,

Felipe Damasio
