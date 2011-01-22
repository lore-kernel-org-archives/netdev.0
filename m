From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipsec: fix IPv4 AH alignment on 32 bits
Date: Fri, 21 Jan 2011 20:20:21 -0800 (PST)
Message-ID: <20110121.202021.32719353.davem@davemloft.net>
References: <4D2F3453.9020203@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.gouault@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753258Ab1AVETr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 23:19:47 -0500
In-Reply-To: <4D2F3453.9020203@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 13 Jan 2011 18:20:19 +0100

> here is a patch to fix alignment of IPv4 AH. Note that this break
> compatiblity for some algorithms (like SHA256) with old kernels
> ... but upstream cannot use SHA256 on IPv4, for example, with a target
> that is RFC compliant.
> 
> I don't know what is the best way to fix this.

We cannot just start rejecting the old 8-byte alignment on input if
Linux has been using an 8-byte alignment since day one.

If you want this change to be considered seriously, you need to relax
the AH4 input check.
