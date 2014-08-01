From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: ldc_connect() should not return
 EINVAL when handshake is in progress.
Date: Thu, 31 Jul 2014 22:11:00 -0700 (PDT)
Message-ID: <20140731.221100.853245332445696300.davem@davemloft.net>
References: <20140731143126.GA7979@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karl.volz@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaHAFLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:11:01 -0400
In-Reply-To: <20140731143126.GA7979@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 31 Jul 2014 10:31:26 -0400

> 
> The LDC handshake could have been asynchronously triggered
> after ldc_bind() enables the ldc_rx() receive interrupt-handler 
> (and thus intercepts incoming control packets)
> and before vio_port_up() calls ldc_connect(). If that is the case,
> ldc_connect() should return 0 and let the state-machine
> progress.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Karl Volz <karl.volz@oracle.com>

This is a sparc architecture change, not a networking one.

Please submit it to the appropriate mailing list, as per the top-level
MAINTAINERS file.

Thanks.
