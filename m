From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] nfp: extend firmware request logic
Date: Thu, 27 Jul 2017 17:26:43 -0700 (PDT)
Message-ID: <20170727.172643.2063365377965177727.davem@davemloft.net>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39048 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdG1A0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 20:26:44 -0400
In-Reply-To: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 26 Jul 2017 11:09:45 -0700

> We have been pondering for some time how to support loading different
> application firmwares onto NFP.  We want to support both users selecting
> one of the firmware images provided by Netronome (which are optimized
> for different use cases each) as well as firmware images created  by 
> users themselves or other companies.
> 
> In the end we decided to go with the simplest solution - depending on
> the right firmware image being placed in /lib/firmware.  This vastly
> simplifies driver logic and also doesn't require any new API.
> 
> Different NICs on one system may want to run different applications
> therefore we first try to load firmware specific to the device (by 
> serial number of PCI slot) and if not present try the device model
> based name we have been using so far.

Series applied, thanks Jakub.
