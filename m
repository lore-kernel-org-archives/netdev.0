From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Avoid expensive divides
Date: Tue, 08 Jan 2008 23:54:54 -0800 (PST)
Message-ID: <20080108.235454.178763736.davem@davemloft.net>
References: <47835E74.4040900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbYAIHyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:54:55 -0500
In-Reply-To: <47835E74.4040900@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 08 Jan 2008 12:28:52 +0100

> We can avoid divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)
> changing vlan_group_get_device()/vlan_group_set_device()  id parameter 
> from signed to
> unsigned.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
