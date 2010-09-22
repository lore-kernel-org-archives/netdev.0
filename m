From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] atl1: fix resume
Date: Wed, 22 Sep 2010 13:53:26 -0700 (PDT)
Message-ID: <20100922.135326.179941282.davem@davemloft.net>
References: <20100922.132341.48506736.davem@davemloft.net>
	<20100922204158.GA1372@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: kronos.it@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332Ab0IVUxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:53:07 -0400
In-Reply-To: <20100922204158.GA1372@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Tettamanti <kronos.it@gmail.com>
Date: Wed, 22 Sep 2010 22:41:58 +0200

> adapter->cmb.cmb is initialized when the device is opened and freed when
> it's closed. Accessing it unconditionally during resume results either
> in a crash (NULL pointer dereference, when the interface has not been
> opened yet) or data corruption (when the interface has been used and
> brought down adapter->cmb.cmb points to a deallocated memory area).
> 
> Cc: stable@kernel.org
> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
> Acked-by: Chris Snook <chris.snook@gmail.com>

Applied.
