From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net/mlx4_en: really allow to change RSS key
Date: Thu, 17 Sep 2015 21:04:28 -0700 (PDT)
Message-ID: <20150917.210428.695179951557334230.davem@davemloft.net>
References: <1442366788.4116.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442366987.4116.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJ3xEMiqyPfcxi7ESGodzwYN059Q09MDUduzy-HhdJMqZ=tizg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eyalpe@mellanox.com, amirv@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbIREE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:04:29 -0400
In-Reply-To: <CAJ3xEMiqyPfcxi7ESGodzwYN059Q09MDUduzy-HhdJMqZ=tizg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 16 Sep 2015 14:05:25 +0300

> On Wed, Sep 16, 2015 at 4:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> When changing rss key, we do not want to overwrite user provided key
>> by the one provided by netdev_rss_key_fill(), which is the host random
>> key generated at boot time.
>>
>> Fixes: 947cbb0ac242 ("net/mlx4_en: Support for configurable RSS hash function")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Eyal Perry <eyalpe@mellanox.com>
>> CC: Amir Vadai <amirv@mellanox.com>
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
> 
> Dave, can you please push it to -stable of >= 3.19 ?

Applied and queued up for -stable, thanks.
