From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: GENET, SYSTEMPORT and DSA
 netconsole
Date: Fri, 31 Jul 2015 15:46:01 -0700 (PDT)
Message-ID: <20150731.154601.1425379374702103079.davem@davemloft.net>
References: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbbGaWqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:46:02 -0400
In-Reply-To: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 31 Jul 2015 11:42:53 -0700

> This patch series adds support for netconsole in the GENET, SYSTEMPORT and DSA
> drivers.
> 
> A small refactoring to the DSA transmit path is required to avoid duplicating
> the dsa_netpoll_send_skb() into each and every tagging protocol supported.
> 
> Testing on e.g: mv643xx_eth and/or e1000e would be much appreciated!
> 
> Changes in v2:
> 
> - properly disable/enable interrupts in GENET and SYSTEMPORT
> 
> - pass the reallocated SKB back to dsa_slave_xmit() in case a tag protocol had to
>   alter the original SKB

Looks good, series applied, thanks Florian.
