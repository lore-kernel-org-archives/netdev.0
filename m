From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sfc: enable 4-tuple UDP RSS hashing
Date: Mon, 07 Nov 2016 13:20:03 -0500 (EST)
Message-ID: <20161107.132003.727799156798583121.davem@davemloft.net>
References: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933043AbcKGSUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:20:05 -0500
In-Reply-To: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 3 Nov 2016 22:10:31 +0000

> EF10 based NICs have configurable RSS hash fields, and can be made to take the
> ports into the hash on UDP (they already do so for TCP).  This patch series
> enables this, in order to improve spreading of UDP traffic.

What does the chip do with fragmented traffic?
