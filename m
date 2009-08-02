From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppol2tp: calls unregister_pernet_gen_device() at
 unload time
Date: Sun, 02 Aug 2009 12:28:11 -0700 (PDT)
Message-ID: <20090802.122811.87769879.davem@davemloft.net>
References: <4A6EFA35.3060309@gmail.com>
	<4A6EFB81.4090105@gmail.com>
	<4A6F017B.4060909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, for.poige+bugzilla.kernel.org@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	gorcunov@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbZHBT2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:28:03 -0400
In-Reply-To: <4A6F017B.4060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Jul 2009 15:47:39 +0200

> Failure to call unregister_pernet_gen_device() can exhaust memory
> if module is loaded/unloaded many times.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
