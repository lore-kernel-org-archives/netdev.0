From: Sharat Masetty <sharat04@gmail.com>
Subject: Multiqueue TX
Date: Sat, 26 Jul 2014 01:31:47 -0600
Message-ID: <CAJzFV37uOC15X+3PR0UJDsBGvMzRP9JRDp16CH8-OiiTv2NM7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:61032 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaGZHbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 03:31:49 -0400
Received: by mail-we0-f169.google.com with SMTP id u56so5104964wes.14
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 00:31:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a question from this David's nice presentation
http://vger.kernel.org/~davem/davem_nyc09.pdf on multiqueue TX. My
questions are on the slide named "PICTURE WITH NON-TRIVIAL QDISC"

1)  What is the rationale behind such an arrangement, where one would
have multiple TX queues pointing to the on single Qdisc?
2)  If the Qdisc in this illustration was a non trivial Qdisc such as
htb, which has multiple leaf Qdisc's, how would the traffic shaping be
preserved?
3) How would the back pressure/flow control of these individual TX
queues work in this case?

Thanks
Sharat
