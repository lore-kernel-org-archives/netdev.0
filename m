From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] packet: Add option to create new fanout
 group with unique id.
Date: Mon, 24 Apr 2017 12:46:51 -0400 (EDT)
Message-ID: <20170424.124651.2233569049227509050.davem@davemloft.net>
References: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maloneykernel@gmail.com, maloney@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974873AbdDXQqx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:46:53 -0400
In-Reply-To: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 21 Apr 2017 10:56:09 -0400

> Fanout uses a per net global namespace. A process that intends to create a
> new fanout group can accidentally join an existing group. It is
> not possible to detect this.
> 
> Add a socket option to specify on the first call to
> setsockopt(..., PACKET_FANOUT, ...) to ensure that a new group is created.
> Also add tests.

Series applied, thanks.
