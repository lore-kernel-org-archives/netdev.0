From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/packet: fix missing net_device reference release
Date: Mon, 15 May 2017 14:25:45 -0400 (EDT)
Message-ID: <20170515.142545.1755990425599910242.davem@davemloft.net>
References: <7daebe52-8542-87cb-551a-1a5b4912f140@taghos.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net,
        willemb@google.com, jarno@ovn.org, andreyknvl@google.com,
        anoob.soman@citrix.com, sowmini.varadhan@oracle.com,
        philip.pettersson@gmail.com, rppt@linux.vnet.ibm.com
To: douglascs@taghos.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933821AbdEOSZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:25:47 -0400
In-Reply-To: <7daebe52-8542-87cb-551a-1a5b4912f140@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Date: Fri, 12 May 2017 15:19:15 -0300

> When using a TX ring buffer, if an error occurs processing a control
> message (e.g. invalid message), the net_device reference is not
> released.
> 
> Fixes c14ac9451c348 ("sock: enable timestamping using control messages")
> Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>

Applied and queued up for -stable, thanks.
