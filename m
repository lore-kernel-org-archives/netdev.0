From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] return useful listenq info in tcp_info and
 INET_DIAG_INFO
Date: Tue, 18 Sep 2007 13:25:19 -0700 (PDT)
Message-ID: <20070918.132519.51700943.davem@davemloft.net>
References: <200709181954.MAA25525@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753133AbXIRUZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:25:25 -0400
In-Reply-To: <200709181954.MAA25525@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 18 Sep 2007 12:54:31 -0700 (PDT)

> Return some useful information such as the maximum listen backlog and the
> current listen backlog in the tcp_info structure and INET_DIAG_INFO.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks Rick, I'll add this to net-2.6.24 with a minor coding
style fix:

> +	}
> +	else {

We don't split up closing braces and else clauses like this,
it eats up a precious extra screen line :-)

	} else {

is the custom.
