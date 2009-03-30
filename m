From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: tx_queue_len question
Date: Mon, 30 Mar 2009 19:49:10 +0200
Message-ID: <b0438a630903301049s7aa796b5t1658999bd4ee1f69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:11883 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705AbZC3RtN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 13:49:13 -0400
Received: by fg-out-1718.google.com with SMTP id 16so367389fgg.17
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 10:49:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Could anyone please tell me how tx_queue_len works? (Or where to take
a look to?).

I am facing two problems with it:
- Using ixp4xx_hss driver, I am not in the same situation if I let the
driver chose tx_queue_len in the initialization, or if I use ifconfig
with the same value (100). With the last it seems to be capable of
storing more frames.
- When I increment it to 300 using ifconfig, the behaviour seems to be
worse than in the case of 100 or 200. Which are the litis of the
value?

Thanks

Miguel =C1ngel =C1lvarez
