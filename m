From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: "addr" module param can't be __initdata
Date: Mon, 05 Nov 2007 21:31:11 -0800 (PST)
Message-ID: <20071105.213111.149736849.davem@davemloft.net>
References: <20071101153629.GA16499@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752143AbXKFFbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 00:31:12 -0500
In-Reply-To: <20071101153629.GA16499@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Thu, 1 Nov 2007 18:36:29 +0300

> sysfs keeps references to module parameters via /sys/module/*/parameters,
> so marking them as __initdata can't work.
> 
> Steps to reproduce:
> 
> 	modprobe decnet
> 	cat /sys/module/decnet/parameters/addr
> 
> BUG: unable to handle kernel paging request at virtual address f88cd410
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied, thanks!
