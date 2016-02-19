From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 2/3] soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
Date: Fri, 19 Feb 2016 21:55:35 +0100
Message-ID: <3375345.7dW4C2g0zE@wuerfel>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com> <1455904724-17952-3-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:55696 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423122AbcBSUzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:55:47 -0500
In-Reply-To: <1455904724-17952-3-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 19 February 2016 12:58:43 Murali Karicheri wrote:
> Rename the pad to sw_data as per description of this field in the hardware
> spec(refer sprugr9 from www.ti.com). Latest version of the document is
> at http://www.ti.com/lit/ug/sprugr9h/sprugr9h.pdf and section 3.1
> Host Packet Descriptor describes this field.
> 
> Define and use a constant for the size of sw_data field similar to
> other fields in the struct for desc and document the sw_data field
> in the header. As the sw_data is not touched by hw, it's type can be
> changed to u32.
> 
> Rename the helpers to match with the updated dma desc field sw_data.
> 
> Cc: Wingman Kwok <w-kwok2@ti.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> CC: Arnd Bergmann <arnd@arndb.de>
> CC: Grygorii Strashko <grygorii.strashko@ti.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
