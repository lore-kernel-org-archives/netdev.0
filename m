From: David Miller <davem@davemloft.net>
Subject: Re: [patch] korina: use resource_size()
Date: Mon, 22 Mar 2010 18:33:39 -0700 (PDT)
Message-ID: <20100322.183339.228963639.davem@davemloft.net>
References: <20100322121145.GK21571@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	n0-1@freewrt.org, jpirko@redhat.com, shemminger@vyatta.com,
	joe@perches.com
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756685Ab0CWBdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 21:33:16 -0400
In-Reply-To: <20100322121145.GK21571@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 22 Mar 2010 15:11:45 +0300

> This size calculation is wrong.  It should be end - start + 1.
> Use resource_size() to calculate it correctly.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
