From: Florian Fainelli <f.fainelli@gmail.com>
Subject: HW accelerated support for setting skb->pkt_type?
Date: Wed, 18 Dec 2013 18:29:37 -0800
Message-ID: <CAGVrzca0P64D181XHjcXMOSMMsyyOEEGjH2KO9bChnN0dAbaTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:37713 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068Ab3LSCaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:30:18 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so472263pdj.26
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 18:30:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I work with two Ethernet controllers which can tell on a per-packet
basis whether this is a broadcast, unicast or multicast, eventually
allowing me to bypass the initial checks done in eth_type_trans().

Is there any other hardware out there which supports that, and is
there any interest in optimizing that operation?

Thanks
-- 
Florian
