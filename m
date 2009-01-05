From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1] tun: signedness warning
Date: Sun, 04 Jan 2009 17:14:56 -0800 (PST)
Message-ID: <20090104.171456.246995886.davem@davemloft.net>
References: <20090101105557.GA4695@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759830AbZAEBOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:14:53 -0500
In-Reply-To: <20090101105557.GA4695@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 1 Jan 2009 11:55:57 +0100

> tun: Eliminate sparse signedness warning
> 
> register_pernet_gen_device() expects 'int*', found via sparse.
> 
>  CHECK   drivers/net/tun.c
>  drivers/net/tun.c:1245:36: warning: incorrect type in argument 1 (different signedness)
>  drivers/net/tun.c:1245:36:    expected int *id
>  drivers/net/tun.c:1245:36:    got unsigned int static [toplevel] *<noident>
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.
