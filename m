From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] macsec: fix configurable ICV length
Date: Mon, 25 Jul 2016 10:55:57 -0700 (PDT)
Message-ID: <20160725.105557.2033026395493420931.davem@davemloft.net>
References: <cover.1469191850.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbcGYRz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:55:58 -0400
In-Reply-To: <cover.1469191850.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Fri, 22 Jul 2016 15:07:55 +0200

> This series provides a fix for macsec configurable ICV length. The 
> maximum length of ICV element has been made compliant to IEEE 802.1AE,
> and error reporting in case of cipher suite configuration failure has been
> improved. Finally, a test has been added to netlink verify() callback in
> order to avoid creation of macsec interfaces having user-provided ICV length
> values that are not supported by the cipher suite.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Series applied and queued up for -stable, thanks.
