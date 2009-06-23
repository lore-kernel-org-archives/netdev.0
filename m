From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: let KS8842 driver depend on HAS_IOMEM
Date: Tue, 23 Jun 2009 04:19:19 -0700 (PDT)
Message-ID: <20090623.041919.163057108.davem@davemloft.net>
References: <20090623073206.GB5955@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.rojfors.ext@mocean-labs.com, schwidefsky@de.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758885AbZFWLTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 07:19:15 -0400
In-Reply-To: <20090623073206.GB5955@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 23 Jun 2009 09:32:18 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Fixes this compile error on s390:
> 
>   CC      drivers/net/ks8842.o
> drivers/net/ks8842.c: In function 'ks8842_select_bank':
> drivers/net/ks8842.c:124: error: implicit declaration of function 'iowrite16'
> drivers/net/ks8842.c: In function 'ks8842_write8':
> drivers/net/ks8842.c:131: error: implicit declaration of function 'iowrite8'
> 
> Cc: Richard Rojfors <richard.rojfors.ext@mocean-labs.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied.
