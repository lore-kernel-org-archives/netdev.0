From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: get netdev_rx_handler_unregister out of locks
Date: Tue, 02 Apr 2013 12:07:29 -0400 (EDT)
Message-ID: <20130402.120729.2051855243392323025.davem@davemloft.net>
References: <1364915716-4857-1-git-send-email-vfalico@redhat.com>
	<1364916362.5113.167.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab3DBQHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 12:07:31 -0400
In-Reply-To: <1364916362.5113.167.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Apr 2013 08:26:02 -0700

> On Tue, 2013-04-02 at 17:15 +0200, Veaceslav Falico wrote:
>> Now that netdev_rx_handler_unregister contains synchronize_net(), we need
>> to call it outside of bond->lock, cause it might sleep. Also, remove the
>> already unneded synchronize_net().
>> 
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
