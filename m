From: David Miller <davem@davemloft.net>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Mon, 09 Apr 2012 15:34:52 -0400 (EDT)
Message-ID: <20120409.153452.1284163346306246866.davem@davemloft.net>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	<4F83316F.20504@lwfinger.net>
	<1333998672.3007.245.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, marc@merlins.org,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118Ab2DITfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 15:35:08 -0400
In-Reply-To: <1333998672.3007.245.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Apr 2012 21:11:12 +0200

> I think Marc posted stack traces showing problem on transmit side.
 ...
> I dont really understand how it can happen, with MTU=1500

Depending upon the configuration and the driver, wireless can need
more headroom.  For encryption an extra 8 bytes are necessary, and the
driver may request a variable amount of extra headroom via
->hw.extra_tx_headroom

What wireless device are we dealing with again?
