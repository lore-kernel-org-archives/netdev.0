From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: check for valid hw address
Date: Fri, 04 Dec 2009 13:30:42 -0800 (PST)
Message-ID: <20091204.133042.10804388.davem@davemloft.net>
References: <20091204115138.GA5532@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757322AbZLDVaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 16:30:35 -0500
In-Reply-To: <20091204115138.GA5532@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Fri, 4 Dec 2009 14:51:38 +0300

> Check for valid hw address.
> 
> Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

Assuming we don't accept your other patch this needs
to return -EINVAL.
