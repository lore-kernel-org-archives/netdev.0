From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpmac: remove hopeless #warning
Date: Mon, 16 Jan 2017 11:54:56 -0500 (EST)
Message-ID: <20170116.115456.1313982115096026749.davem@davemloft.net>
References: <20170116132113.2056012-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdAPQy6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:54:58 -0500
In-Reply-To: <20170116132113.2056012-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 16 Jan 2017 14:20:54 +0100

> The #warning was present 10 years ago when the driver first got merged.
> As the platform is rather obsolete by now, it seems very unlikely that
> the warning will cause anyone to fix the code properly.
> 
> kernelci.org reports the warning for every build in the meantime, so
> I think it's better to just turn it into a code comment to reduce
> noise.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Agreed, applied, thanks Arnd.
