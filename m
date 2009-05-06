From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make inet_twsk_put similar to sock_put
Date: Wed, 06 May 2009 16:51:06 -0700 (PDT)
Message-ID: <20090506.165106.152184195.davem@davemloft.net>
References: <20090506044819.GL2675@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332AbZEFXvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:51:11 -0400
In-Reply-To: <20090506044819.GL2675@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 6 May 2009 01:48:19 -0300

> By separating the freeing code from the refcounting decrementing.
> Probably reducing icache pressure when we still have reference counts to
> go.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6, thanks!
