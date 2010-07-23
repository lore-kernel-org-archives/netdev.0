From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] be2net: code to support tx rate
 configuration on virtual functions
Date: Fri, 23 Jul 2010 12:44:00 -0700 (PDT)
Message-ID: <20100723.124400.59666026.davem@davemloft.net>
References: <20100723115201.GA24975@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753038Ab0GWTno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 15:43:44 -0400
In-Reply-To: <20100723115201.GA24975@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 23 Jul 2010 17:22:13 +0530

> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, but:

> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index 344e062..32ae324 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -1730,3 +1730,37 @@ err:
...
> +err:
> +	spin_unlock_bh(&adapter->mcc_lock);
> +	return status;
> +}
> +

Adds trailing empty line at EOF, which GIT warns about, so I killed
it when adding this patch to the tree.
