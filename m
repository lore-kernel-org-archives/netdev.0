From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: remove econet_packet_type on unload
Date: Tue, 14 Aug 2007 17:24:31 -0700 (PDT)
Message-ID: <20070814.172431.18304665.davem@davemloft.net>
References: <20070814212553.GB5873@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751974AbXHOAYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 20:24:33 -0400
In-Reply-To: <20070814212553.GB5873@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 15 Aug 2007 01:25:53 +0400

> Steps to reproduce:
> 
> 	modprobe econet
> 	rmmod econet
> 	modprobe econet
> 
> Unable to handle kernel paging request at ffffffff8870a098 RIP: 
>  [<ffffffff8040bfb8>] dev_add_pack+0x48/0x90
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Patch applied, thanks a lot Alexey.
