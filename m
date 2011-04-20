From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix a DLPAR bug on ehea_rereg_mrs().
Date: Wed, 20 Apr 2011 01:42:27 -0700 (PDT)
Message-ID: <20110420.014227.179922460.davem@davemloft.net>
References: <1303241962-32285-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750839Ab1DTInB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:43:01 -0400
In-Reply-To: <1303241962-32285-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Tue, 19 Apr 2011 16:39:22 -0300

> We are currently continuing if ehea_restart_qps() fails, when we
> do a memory DLPAR (remove or add more memory to the system).
> 
> This patch just let the NAPI disabled if the ehea_restart_qps()
> fails.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
