From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Mon, 31 Jul 2006 13:23:24 -0700 (PDT)
Message-ID: <20060731.132324.65197403.davem@davemloft.net>
References: <20060730.153004.45876935.davem@davemloft.net>
	<20060731153948.GB17540@ms2.inr.ac.ru>
	<m3r701zgku.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15283
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932510AbWGaUX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 16:23:26 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3r701zgku.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 31 Jul 2006 22:04:33 +0200

> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:
> 
> > All the rest of places just check, that there is enough space
> > for their immediate needs. If dev->hard_header() is NULL, it means that
> > stack does not need any space at all, so that it does not need to worry.
> 
> Why do you think dev->hard_header == NULL means there is no need for
> header space? Isn't it dev->hard_header_len = 0? Why would a device
> set hard_header_len to non-zero if it doesn't need header space?

If you have headers to prepend for your device, why do you set the
header building function to NULL? :-)
