From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: fix duplicate loglevel in module load message
Date: Tue, 22 Sep 2009 14:25:56 -0700 (PDT)
Message-ID: <20090922.142556.76384742.davem@davemloft.net>
References: <4AB8D9B3.4010805@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	a.beregalov@gmail.com
To: alan-jenkins@tuffmail.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066AbZIVVZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:25:38 -0400
In-Reply-To: <4AB8D9B3.4010805@tuffmail.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date: Tue, 22 Sep 2009 15:05:39 +0100

> This was introduced by b93d58 "8139*: convert printk() to pr_<foo>()":
> 
> [ 2256252443 ] <6>8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
> 
> The "version" string is printed using pr_info(), so it doesn't need to
> include a loglevel.
> 
> Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> CC: Alexander Beregalov <a.beregalov@gmail.com>

Applied.
