From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xdp: use common helper for netlink extended ack
 reporting
Date: Wed, 03 May 2017 09:51:50 -0400 (EDT)
Message-ID: <20170503.095150.1638542471861793284.davem@davemloft.net>
References: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbdECNvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:51:52 -0400
In-Reply-To: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  3 May 2017 00:39:17 +0200

> Small follow-up to d74a32acd59a ("xdp: use netlink extended ACK reporting")
> in order to let drivers all use the same NL_SET_ERR_MSG_MOD() helper macro
> for reporting. This also ensures that we consistently add the driver's
> prefix for dumping the report in user space to indicate that the error
> message is driver specific and not coming from core code. Furthermore,
> NL_SET_ERR_MSG_MOD() now reuses NL_SET_ERR_MSG() and thus makes all macros
> check the pointer as suggested.
> 
> References: https://www.spinics.net/lists/netdev/msg433267.html
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
