From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: sunhme: infinite retries when link is down
Date: Mon, 30 Mar 2009 04:15:17 +0400
Message-ID: <a4423d670903291715w21407732w1652e02e15339e90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:53857 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbZC3APU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 20:15:20 -0400
Received: by ewy9 with SMTP id 9so1849337ewy.37
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 17:15:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I found that sunhme driver produces many annoing messages like this

[ 2045.529735] eth0: Auto-Negotiation unsuccessful, trying force link mode
[ 2055.128729] eth0: Link down, cable problem?
[ 2067.127274] eth0: Auto-Negotiation unsuccessful, trying force link mode
[ 2076.726260] eth0: Link down, cable problem?
[ 2098.783650] eth0: Auto-Negotiation unsuccessful, trying force link mode
[ 2108.382639] eth0: Link down, cable problem?
[ 2120.381189] eth0: Auto-Negotiation unsuccessful, trying force link mode
[ 2129.980186] eth0: Link down, cable problem?

Is it a normal behaviour?

Can we just say "Link down" and do not try to reset it?

2.6.29-05093-gc31f403

Thanks.
