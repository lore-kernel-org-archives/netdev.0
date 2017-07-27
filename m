From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] netvsc fixes and new features
Date: Wed, 26 Jul 2017 23:59:19 -0700 (PDT)
Message-ID: <20170726.235919.298200628681187723.davem@davemloft.net>
References: <20170726234029.7342-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net, devel@linuxdriverproject.org,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdG0G7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 02:59:22 -0400
In-Reply-To: <20170726234029.7342-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 26 Jul 2017 16:40:19 -0700

> The next group of patches aims to reduce the driver memory footprint
> by reducing the size of the per-device receive and send buffers, and
> the per-channel receive completion queue.

Sorry Stephen, I have to draw the line with those module parameters.

Search out alternate mechanism which can work at run time, such as
using devlink or similar.

Don't tell me it's "impossible" or "hard", simply do.

Thanks.
