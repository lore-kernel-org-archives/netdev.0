From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/8] net/mlx4_en: Remove redundant code from
 RX/GRO path
Date: Sun, 02 Nov 2014 06:28:12 -0800
Message-ID: <1414938492.31792.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	 <1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
	 <1414695631.15352.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMjw9rRLBTEXT3cw0+CPRyvJgNbKVHpnmsukas-r=QwmyA@mail.gmail.com>
	 <1414725541.499.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMiDnv9=nvvJ1m7_taoSncdmgv4GJVR8DiD5t5GCsFig1A@mail.gmail.com>
	 <1414770362.27538.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54563B12.1040905@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62638 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaKBO2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 09:28:15 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so3755853iec.7
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 06:28:14 -0800 (PST)
In-Reply-To: <54563B12.1040905@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-02 at 16:09 +0200, Or Gerlitz wrote:

> Hi Eric,
> 
> For the time being, I'll drop from this series thischange and the 
> following ones which depend on it. So can pick in the earlier patches of 
> the series, and investigate in parallel thevarious optionsw.r.t GRO here.

Thanks Or !

I posted first patch to allow implementing this better GRO strategy
(https://patchwork.ozlabs.org/patch/405892/ )
