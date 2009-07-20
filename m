From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root.
 Now=15 size=11 bits
Date: Mon, 20 Jul 2009 07:41:23 -0700 (PDT)
Message-ID: <20090720.074123.75633320.davem@davemloft.net>
References: <20090707235029.GA8207@ami.dom.local>
	<4A565449.4050403@itcare.pl>
	<20090714194100.GA7952@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pstaszewski@itcare.pl, netdev@vger.kernel.org, robert@robur.slu.se,
	jorge@dti2.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751299AbZGTOlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:41:18 -0400
In-Reply-To: <20090714194100.GA7952@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 14 Jul 2009 21:41:00 +0200

> ipv4: Fix inflate_threshold_root automatically
> 
> During large updates there could be triggered warnings like: "Fix
> inflate_threshold_root. Now=25 size=11 bits" if inflate() of the root
> node isn't finished in 10 loops. It should be much rarer now, after
> changing the threshold from 15 to 25, and a temporary problem, so
> this patch tries to handle it automatically using a fix variable to
> increase by one inflate threshold for next root resizes (up to the 35
> limit, max fix = 10). The fix variable is decreased when root's
> inflate() finishes below 7 loops (even if some other, smaller table/
> trie is updated -- for simplicity the fix variable is global for now).
> 
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Reported-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
> Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
