From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net] net/mlx4_en: really allow to change RSS key
Date: Wed, 16 Sep 2015 14:05:25 +0300
Message-ID: <CAJ3xEMiqyPfcxi7ESGodzwYN059Q09MDUduzy-HhdJMqZ=tizg@mail.gmail.com>
References: <1442366788.4116.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442366987.4116.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35531 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbbIPLF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 07:05:26 -0400
Received: by oiww128 with SMTP id w128so120949250oiw.2
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 04:05:26 -0700 (PDT)
In-Reply-To: <1442366987.4116.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2015 at 4:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When changing rss key, we do not want to overwrite user provided key
> by the one provided by netdev_rss_key_fill(), which is the host random
> key generated at boot time.
>
> Fixes: 947cbb0ac242 ("net/mlx4_en: Support for configurable RSS hash function")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eyal Perry <eyalpe@mellanox.com>
> CC: Amir Vadai <amirv@mellanox.com>

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Dave, can you please push it to -stable of >= 3.19 ?
