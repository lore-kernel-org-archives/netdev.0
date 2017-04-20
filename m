From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: address two poll() flakes
Date: Thu, 20 Apr 2017 15:42:28 -0400 (EDT)
Message-ID: <20170420.154228.365871460655376820.davem@davemloft.net>
References: <20170418164552.29261-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48268 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947097AbdDTTma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:42:30 -0400
In-Reply-To: <20170418164552.29261-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 18 Apr 2017 09:45:50 -0700

> Some packetdrill tests are failing when host kernel is using ASAN
> or other debugging infrastructure.
> 
> I was able to fix the flakes by making sure we were not
> sending wakeup events too soon.

Series applied, thanks Eric.
