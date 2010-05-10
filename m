From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] net: adjust handle_macvlan to pass port
 struct to hook
Date: Mon, 10 May 2010 16:35:34 +0200
Message-ID: <4BE819B6.3020101@trash.net>
References: <20100506113352.GB3406@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47296 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab0EJOfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:35:34 -0400
In-Reply-To: <20100506113352.GB3406@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Now there's null check here and also again in the hook. Looking at bridge bits
> which are simmilar, port structure is rcu_dereferenced right away in
> handle_bridge and passed to hook. Looks nicer.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Looks fine, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
