From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-eem: bad crc checking
Date: Thu, 16 Jul 2009 18:10:30 -0700 (PDT)
Message-ID: <20090716.181030.254565459.davem@davemloft.net>
References: <5ca532980907160908k3c18fd16k18e17f92a18de5a8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vincent.cuissard@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933900AbZGQBKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:10:25 -0400
In-Reply-To: <5ca532980907160908k3c18fd16k18e17f92a18de5a8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent CUISSARD <vincent.cuissard@gmail.com>
Date: Thu, 16 Jul 2009 18:08:58 +0200

> When the driver received an EEM packet with CRC option enabled, driver must
> compute and check the CRC of the Ethernet data. Previous version computes CRC
> on Ethernet data plus the original CRC value. Skbuff is correctly trimed but
> the old length is used when CRC is computed.
> 
> 
> Signed-off-by: Vincent CUISSARD <vincent.cuissard@gmail.com>

Applied, but you need to fix your patch submission so that your
email client doesn't corrupt the patch by splitting up longer
lines like it did here.

Thanks.
