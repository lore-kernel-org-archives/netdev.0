From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: don't report RX hash keys to ethtool when RSS
 wasn't enabled
Date: Wed, 04 Jan 2017 14:18:31 -0500 (EST)
Message-ID: <20170104.141831.1785899010781855952.davem@davemloft.net>
References: <5a4ac10d-3b4b-bf48-e4ca-c435eed29dc3@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bkenward@solarflare.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968914AbdADTSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:18:33 -0500
In-Reply-To: <5a4ac10d-3b4b-bf48-e4ca-c435eed29dc3@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 4 Jan 2017 15:10:56 +0000

> If we failed to set up RSS on EF10 (e.g. because firmware declared
>  RX_RSS_LIMITED), ethtool --show-nfc $dev rx-flow-hash ... should report
>  no fields, rather than confusingly reporting what fields we _would_ be
>  hashing on if RSS was working.
> 
> Fixes: dcb4123cbec0 ("sfc: disable RSS when unsupported")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
