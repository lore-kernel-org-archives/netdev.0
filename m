From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 2/2]r8169: remove redundant RTL_W32
Date: Thu, 03 Jun 2010 12:29:50 -0700 (PDT)
Message-ID: <20100603.122950.193702477.davem@davemloft.net>
References: <20100603112721.GD24909@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45360
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915Ab0FCT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 15:29:40 -0400
In-Reply-To: <20100603112721.GD24909@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Thu, 3 Jun 2010 19:27:23 +0800

> Writting "cmd" into "CounterAddrLow" twice is redundant.
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

I definitely think this is being done on purpose.
