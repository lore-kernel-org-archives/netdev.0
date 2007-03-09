From: David Miller <davem@davemloft.net>
Subject: Re: about : [NET]: Replace CONFIG_NET_DEBUG with sysctl.
Date: Thu, 08 Mar 2007 22:37:48 -0800 (PST)
Message-ID: <20070308.223748.74750176.davem@davemloft.net>
References: <20070308205305.582324346@linux-foundation.org>
	<20070308.204209.69409441.davem@davemloft.net>
	<45F0FFE7.1080304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993004AbXCIGh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 01:37:57 -0500
In-Reply-To: <45F0FFE7.1080304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 09 Mar 2007 07:34:15 +0100

> I gently ask that any new sysctl is '__read_mostly' tagged.

People are lazy because you are so gifted at finding this
stuff :-)

> [PATCH] NET : New sysctls should use __read_mostly tags
> 
> net_msg_warn should be placed in the read_mostly section, to avoid performance 
> problems on SMP
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.
