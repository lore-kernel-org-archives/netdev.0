From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 08:07:56 +0100
Message-ID: <1322550476.2970.74.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37301 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab1K2HIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 02:08:02 -0500
Received: by eaak14 with SMTP id k14so2671390eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 23:08:01 -0800 (PST)
In-Reply-To: <1322550138.2970.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 08:02 +0100, Eric Dumazet a =C3=A9crit=
 :

> TSO on means a low priority 65Kbytes packet can be in TX ring right
> before the high priority packet. If you cant afford the delay, you lo=
se.
>=20


By the way, I hope TSO is off for wifi adapters.

At least here its off..

# ethtool -k wlan0
Offload parameters for wlan0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off


0c:00.0 Network controller: Broadcom Corporation BCM4311 802.11a/b/g (r=
ev 01)
