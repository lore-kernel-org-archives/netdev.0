From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ehea: add the correct LRO status at dev->features
Date: Mon, 6 Dec 2010 08:48:24 -0800
Message-ID: <20101206084824.637d6b29@nehalam>
References: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42877 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab0LFQs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 11:48:27 -0500
In-Reply-To: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Dec 2010 14:39:42 -0200
leitao@linux.vnet.ibm.com wrote:

> Currently ehea is not setting NETIF_F_LRO, and it is not providing
> a callback for get_flags on ethtool. This patch fixes it.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

More importantly, ehea does not support set_flags to disable LRO.

I will be more blunt. Any device that supports LRO and does
not have the necessary interface to disable it is broken and should
not be used.

-- 
