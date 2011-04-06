From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 02/12] skge: implement set_phys_id
Date: Wed, 06 Apr 2011 14:30:55 -0700 (PDT)
Message-ID: <20110406.143055.241913046.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184501.450494215@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755465Ab1DFVbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:31:32 -0400
In-Reply-To: <20110404184501.450494215@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 11:43:42 -0700

> Implement set_phys_id led control on SysKonnect board.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, although I had to fix:

> +	case ETHTOOL_ID_ACTIVE:
> +		return -1;

to return -EINVAL.
