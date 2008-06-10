From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] add missing lance_* exports
Date: Tue, 10 Jun 2008 18:22:10 -0400
Message-ID: <484EFE92.4000800@pobox.com>
References: <20080609222216.GD1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39002 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760058AbYFJWWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:22:12 -0400
In-Reply-To: <20080609222216.GD1987@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch fixes the following build error:
> 
> <--  snip  -->
> 
> ...
>   Building modules, stage 2.
>   MODPOST 1203 modules
> ERROR: "lance_open" [drivers/net/mvme147.ko] undefined!
> ERROR: "lance_close" [drivers/net/mvme147.ko] undefined!
> ERROR: "lance_tx_timeout" [drivers/net/mvme147.ko] undefined!
> ERROR: "lance_set_multicast" [drivers/net/mvme147.ko] undefined!
> ERROR: "lance_start_xmit" [drivers/net/mvme147.ko] undefined!
> ...
> make[2]: *** [__modpost] Error 1
> 
> <--  snip  -->
> 
> Reported-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

applied


