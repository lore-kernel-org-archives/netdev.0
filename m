From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 1 Dec 2006 13:49:03 +0100
Message-ID: <20061201124903.GE8693@postel.suug.ch>
References: <1164972613.3562.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21950 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1031275AbWLAMsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 07:48:43 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1164972613.3562.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-01 06:30
> hopefully no mime crap
> cheers,
> jamal

> [GENETLINK] max cmd boundary check
> 
> We need to boundary check for commands being registered.
> 
> Signed-off-by: Jamal Hadi Salim<hadi@cyberus.ca>

I can't see why this should be required. genl_register_ops()
enforces a unique command id and genl_ops->cmd is u8 so
there is no way to register more than 256 commands anyway.
