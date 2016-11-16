From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB
 dump
Date: Wed, 16 Nov 2016 11:27:35 -0500 (EST)
Message-ID: <20161116.112735.19078311822311561.davem@davemloft.net>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
        <1479305343-13167-7-git-send-email-jiri@resnulli.us>
        <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbcKPQ1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:27:38 -0500
In-Reply-To: <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 16 Nov 2016 15:51:01 +0100

> I don't see a way around doing a journal like in filesystems somehow,

We really just need a sequence counter incremented for each insert/remove,
and restart the dump from the beginning if it changes mid-dump.
