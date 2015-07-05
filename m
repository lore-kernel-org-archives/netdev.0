From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] mlx4: TCP/UDP packets have L4 hash
Date: Sun, 05 Jul 2015 23:33:21 +0200
Message-ID: <1436132001.26467.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55999EA3.4010303@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Ido Shamay <idos@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35265 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbGEVd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 17:33:26 -0400
Received: by wiga1 with SMTP id a1so213700268wig.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 14:33:24 -0700 (PDT)
In-Reply-To: <55999EA3.4010303@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-06 at 00:16 +0300, Ido Shamay wrote:

> We can have a relaxation of the condition  by looking only at TCP/UDP 
> CQE indication (without check-sum indications)
> This can cover us also when device rx-checksuming feature is off.
> Do we want it or a correlation between check-sum and l4_hash is needed?

I thought about that, but this was adding a more complex test in fast
path.

Not sure we should care here, as nobody would disable hardware checksum
if they care about performance.
