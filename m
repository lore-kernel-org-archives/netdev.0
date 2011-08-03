From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH] mlx4: Fixing Ethernet unicast packet steering
Date: Wed, 3 Aug 2011 11:58:59 -0700
Message-ID: <CAL1RGDU+=wX40J_uktWxMiHNx5Sed-d3b2J4_4JTg=tyqbKsEg@mail.gmail.com>
References: <4E39594C.4090808@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog110.obsmtp.com ([74.125.245.88]:46262 "HELO
	na3sys010aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755197Ab1HCS7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 14:59:21 -0400
In-Reply-To: <4E39594C.4090808@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For older FW versions, fixing the usage of per port Mac table.
> For each port we must define the base QP number, which is passed
> to the HW.
> Setting the correct value in SET_PORT FW command to enable the steering.
>
> Reported-by: Roland Dreier <roland@purestorage.com>

Thanks, testing this now.
