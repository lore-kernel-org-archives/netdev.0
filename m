From: =?ISO-8859-1?Q?Bj=F8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: Problem removing netns
Date: Wed, 22 Aug 2012 13:59:25 +0200
Message-ID: <CAJO99T=qtzw_4LZOg9eXmPrjKELDzxCHKBEabwd50N9unS7kbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51641 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432Ab2HVL70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 07:59:26 -0400
Received: by wgbdr13 with SMTP id dr13so784214wgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 04:59:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am experimenting with netns (Linux precision 3.2.0-0.bpo.2-amd64 #1
SMP Sun Jun 3 21:40:57 UTC 2012 x86_64 GNU/Linux)
and have problems removing unused namespace, this is what I do:

ip netns add netns_one
ip netns add netns_two
ip link add name if_one type veth peer name if_one_peer
ip link add name if_two type veth peer name if_two_peer
ip link set dev if_one_peer netns netns_one
ip link set dev if_two_peer netns netns_two

ip netns exec netns_one bash

# in other terminal:

ip netns delete netns_two

# => Cannot remove /var/run/netns/netns_two: Device or resource busy

Is this expected  behaviour? If so, what is the correct process to
actually remove a namespace?

-- 
Bj(/)rnar
