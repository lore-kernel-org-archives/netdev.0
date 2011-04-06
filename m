From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 06 Apr 2011 12:56:37 -0700 (PDT)
Message-ID: <20110406.125637.70201394.davem@davemloft.net>
References: <1301720283-25038-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, bhutchings@solarflare.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455Ab1DFT5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:57:13 -0400
In-Reply-To: <1301720283-25038-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Fri,  1 Apr 2011 21:58:03 -0700

> o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
>   but it is tigtly coupled with RX flow hash configuration.
> o Patches for qlcnic and netxen_nic driver supporting rx channel will follow
>   soon.
> o This patch is reworked on Ben Hutchings "ethtool: NUMA affinity control" patch,
>   dropping the affinity control from it.
> 
> Ben Hutching:
> o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
>   queues so that most channels combine RX and TX work.
> o Please could you use a kernel-doc comment to describe the structure.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Ben, are you currently OK with this patch?

There was some back and forth, and I just want to make sure all of the
issues you raised were addressed to your satisfaction.

Thanks.
