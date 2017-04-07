From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] Use net_device_stats from struct
 net_device
Date: Fri, 07 Apr 2017 07:06:50 -0700 (PDT)
Message-ID: <20170407.070650.1416475585266262678.davem@davemloft.net>
References: <20170407081739.5243-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932962AbdDGOGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:06:54 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri,  7 Apr 2017 10:17:25 +0200

> Along the lines of previous patches, switch (almost) all remaining net
> drivers to use net_device_stats from net_device instead of including a
> copy of it in their netdev_priv struct.

I'll apply this series because it moves things in a positive direction,
but yeah these drivers should in the long term use the 64-bit link stats
which overflow less often.
