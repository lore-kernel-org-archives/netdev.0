From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27.2] datagram handling routines :
 mapping/unmapping paged data in soft IRQ
Date: Mon, 11 May 2009 16:36:52 -0700 (PDT)
Message-ID: <20090511.163652.156749735.davem@davemloft.net>
References: <54466B0E862D654998371DCA86B6FE2F4B6D47@adept-srv2.adept.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alan@redhat.com
To: Luc.Goria@adept-telecom.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755942AbZEKXg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 19:36:56 -0400
In-Reply-To: <54466B0E862D654998371DCA86B6FE2F4B6D47@adept-srv2.adept.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luc Goria" <Luc.Goria@adept-telecom.fr>
Date: Mon, 11 May 2009 15:32:21 +0200

> 
> Kernel crashes when a network module tries to copy a datagram to iovec in soft IRQ with paged data.
> The problem is that kunmap function can't be called in IRQ.
> All calls to kmap/kunmap fonctions are replaced by calls to kmap_skb_frag/kunmap_skb_frag when paged data are involved.
> 
>  <<datagram.c.patch>> 
> Signed-off-by: Luc GORIA <luc.goria@adept-telecom.fr>

What network module does this?  You're not supposed to.

