From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: adjust handle_macvlan to pass port
 struct to hook
Date: Sat, 15 May 2010 23:48:26 -0700 (PDT)
Message-ID: <20100515.234826.135552334.davem@davemloft.net>
References: <20100506113352.GB3406@psychotron.lab.eng.brq.redhat.com>
	<4BE819B6.3020101@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337Ab0EPGsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:48:17 -0400
In-Reply-To: <4BE819B6.3020101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 10 May 2010 16:35:34 +0200

> Jiri Pirko wrote:
>> Now there's null check here and also again in the hook. Looking at bridge bits
>> which are simmilar, port structure is rcu_dereferenced right away in
>> handle_bridge and passed to hook. Looks nicer.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Looks fine, thanks.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
