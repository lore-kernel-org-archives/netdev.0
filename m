From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: core changes for supporting
 multiple Rx queues
Date: Mon, 9 Mar 2015 15:11:37 -0700
Message-ID: <CAGVrzcbsVeJ5-GYxSwje4prN2RgTJ0f_PhX8Zdg_AtX5u4_ymw@mail.gmail.com>
References: <20150309204001.215FB2214B7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:44119 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbCIWMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:12:18 -0400
Received: by iery20 with SMTP id y20so14328506ier.11
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:12:17 -0700 (PDT)
In-Reply-To: <20150309204001.215FB2214B7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-09 13:40 GMT-07:00 Petri Gynther <pgynther@google.com>:
> 1. Add struct bcmgenet_rx_ring to hold all necessary information
>    for a single Rx queue.
> 2. Add bcmgenet_init_rx_queues() to initialize all Rx queues.
> 3. Modify bcmgenet_init_rx_ring() to initialize a single Rx queue.
> 4. Modify Rx interrupt path code to use per-queue data.
> 5. Modify bcmgenet_rx_refill() to use RxCB->bd_addr.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--
Florian
